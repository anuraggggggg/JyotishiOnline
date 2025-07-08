import 'dart:developer';

import 'package:AstrowayCustomer/controllers/astromallController.dart';
import 'package:AstrowayCustomer/controllers/splashController.dart';
import 'package:AstrowayCustomer/views/webpaymentScreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/walletController.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;
import '../utils/services/api_helper.dart';
import '../widget/commonAppbar.dart';

// ignore: must_be_immutable
class PaymentInformationScreen extends StatefulWidget {
  final double amount;
  final int? flag;
  final int? cashback;
  PaymentInformationScreen(
      {Key? key, required this.amount, this.flag, this.cashback = 0})
      : super(key: key);

  @override
  State<PaymentInformationScreen> createState() =>
      _PaymentInformationScreenState();
}

class _PaymentInformationScreenState extends State<PaymentInformationScreen> {
  final WalletController walletController = Get.find<WalletController>();
  SplashController splashController = Get.find<SplashController>();
  AstromallController astromallController = Get.find<AstromallController>();
  APIHelper apiHelper = APIHelper();

  int? paymentMode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: kIsWeb
          ? AppBar(
              leading: SizedBox(),
            )
          : PreferredSize(
              preferredSize: Size.fromHeight(56),
              child: CommonAppBar(
                title: 'Payment Information',
              )),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GetBuilder<WalletController>(builder: (c) {
            return kIsWeb
                ? Container(
                    width: MediaQuery.of(context).size.width * 1,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.60,
                            child: Column(
                              children: [
                                Card(
                                  elevation: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Payment Details',
                                                style: Get
                                                    .textTheme.titleMedium!
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 15))
                                            .tr(),
                                        SizedBox(height: 5),
                                        widget.flag == 1
                                            ? Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text('${astromallController.astroProductbyId[0].name}')
                                                      .tr(),
                                                  Text(
                                                      '${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${double.parse(astromallController.astroProductbyId[0].amount.toString())}'),
                                                ],
                                              )
                                            : SizedBox(),
                                        SizedBox(height: 5),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Total Amount').tr(),
                                            Text(
                                                '${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${widget.amount}'),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('GST ${global.getSystemFlagValue(global.systemFlagNameList.gst)}%')
                                                .tr(),
                                            Expanded(
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                    '${widget.amount * double.parse(global.getSystemFlagValue(global.systemFlagNameList.gst)) / 100}'),
                                              ),
                                            )
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Total Payable Amount',
                                                    style: Get
                                                        .textTheme.titleMedium!
                                                        .copyWith(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500))
                                                .tr(),
                                            Text(
                                                '${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${(widget.amount + widget.amount * double.parse(global.getSystemFlagValue(global.systemFlagNameList.gst)) / 100).toStringAsFixed(2)}',
                                                style: Get
                                                    .textTheme.titleMedium!
                                                    .copyWith(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 15),
                          SizedBox(
                            height: 60,
                            width: MediaQuery.of(context).size.width * 0.60,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextButton(
                                onPressed: () async {
                                  global.showOnlyLoaderDialog(Get.context);
                                  await apiHelper
                                      .addAmountInWallet(
                                    amount: double.parse(
                                        "${(widget.amount + widget.amount * double.parse(global.getSystemFlagValue(global.systemFlagNameList.gst)) / 100).toStringAsFixed(2)}"),
                                    cashback: 0,
                                  )
                                      .then((value) {
                                    if (value['status'] == 200) {
                                      global.hideLoader();
                                      print("jkasdjksa");
                                      log("$value");
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  PaymentScreen(
                                                    url: value['url'],
                                                  )));
                                    }
                                  });
                                },
                                child: Text('Proceed to Pay',
                                        style: Get.textTheme.titleMedium!
                                            .copyWith(
                                                fontSize: 12,
                                                color: Colors.white))
                                    .tr(),
                                style: ButtonStyle(
                                  padding: WidgetStateProperty.all(
                                      EdgeInsets.all(0)),
                                  backgroundColor: WidgetStateProperty.all(
                                      Get.theme.primaryColor),
                                  shape: WidgetStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ]),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        SizedBox(
                          width: double.infinity,
                          child: Column(
                            children: [
                              Card(
                                elevation: 1,
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Payment Details',
                                              style: Get.textTheme.titleMedium!
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15))
                                          .tr(),
                                      SizedBox(height: 5),
                                      widget.flag == 1
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text('${astromallController.astroProductbyId[0].name}')
                                                    .tr(),
                                                Text(
                                                    '${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${double.parse(astromallController.astroProductbyId[0].amount.toString())}'),
                                              ],
                                            )
                                          : SizedBox(),
                                      SizedBox(height: 5),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Total Amount').tr(),
                                          Text(
                                              '${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${widget.amount}'),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('GST ${global.getSystemFlagValue(global.systemFlagNameList.gst)}%')
                                              .tr(),
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                  '${widget.amount * double.parse(global.getSystemFlagValue(global.systemFlagNameList.gst)) / 100}'),
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Total Payable Amount',
                                                  style: Get
                                                      .textTheme.titleMedium!
                                                      .copyWith(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500))
                                              .tr(),
                                          Text(
                                              '${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${(widget.amount + widget.amount * double.parse(global.getSystemFlagValue(global.systemFlagNameList.gst)) / 100).toStringAsFixed(2)}',
                                              style: Get.textTheme.titleMedium!
                                                  .copyWith(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 15),
                      ]);
          }),
        ),
      ),
      bottomSheet: kIsWeb
          ? SizedBox()
          : SizedBox(
              height: 60,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: () async {
                    global.showOnlyLoaderDialog(Get.context);
                    await apiHelper
                        .addAmountInWallet(
                      amount: double.parse(
                          "${(widget.amount + widget.amount * double.parse(global.getSystemFlagValue(global.systemFlagNameList.gst)) / 100).toStringAsFixed(2)}"),
                      cashback: 0,
                    )
                        .then((value) {
                      if (value['status'] == 200) {
                        global.hideLoader();
                        print("jkasdjksa");
                        log("$value");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentScreen(
                              url: value['url'],
                            ),
                          ),
                        );
                      }
                    });
                  },
                  child: Text(
                    'Proceed to Pay',
                    style: Get.textTheme.titleMedium!
                        .copyWith(fontSize: 12, color: Colors.white),
                  ).tr(),
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all(EdgeInsets.all(0)),
                    backgroundColor:
                        WidgetStateProperty.all(Get.theme.primaryColor),
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
