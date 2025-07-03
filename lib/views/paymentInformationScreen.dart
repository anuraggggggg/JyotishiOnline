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
                                        SizedBox(
                                          height: 5,
                                        ),
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
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Total Amount').tr(),
                                            Text(
                                                '${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${widget.amount}'),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
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
                                        SizedBox(
                                          height: 5,
                                        ),
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
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('After Cashback you will get',
                                                    style: Get
                                                        .textTheme.titleMedium!
                                                        .copyWith(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500))
                                                .tr(),
                                            Text(
                                                '${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${((widget.amount + int.parse(widget.cashback.toString()) / 100).toStringAsFixed(2))}',
                                                style: Get
                                                    .textTheme.titleMedium!
                                                    .copyWith(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
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
                                    cashback:
                                        (int.parse(widget.amount.toString()) *
                                                (int.parse(widget.cashback
                                                        .toString()) /
                                                    100))
                                            .toInt(),
                                    userId: global.user.id!,
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
                                                    // url: value['url'],
                                                    amount:
                                                        '${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${((widget.amount + widget.amount * int.parse(widget.cashback.toString()) / 100)).toStringAsFixed(2)}',
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
                                      SizedBox(
                                        height: 5,
                                      ),
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
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Total Amount').tr(),
                                          Text(
                                              '${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${widget.amount}'),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
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
                                      SizedBox(
                                        height: 5,
                                      ),
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
                                      widget.cashback == 0
                                          ? SizedBox()
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text('Cashback',
                                                        style: Get.textTheme
                                                            .titleMedium!
                                                            .copyWith(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500))
                                                    .tr(),
                                                Text(
                                                    '${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${widget.amount * int.parse(widget.cashback.toString()) / 100}',
                                                    style: Get
                                                        .textTheme.titleMedium!
                                                        .copyWith(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500)),
                                              ],
                                            ),
                                      widget.cashback == 0
                                          ? SizedBox()
                                          : SizedBox(
                                              height: 5,
                                            ),
                                      widget.cashback == 0
                                          ? SizedBox()
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text('After Cashback you will Get',
                                                        style: Get.textTheme
                                                            .titleMedium!
                                                            .copyWith(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500))
                                                    .tr(),
                                                Text(
                                                    '${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${((widget.amount + widget.amount * int.parse(widget.cashback.toString()) / 100)).toStringAsFixed(2)}',
                                                    style: Get
                                                        .textTheme.titleMedium!
                                                        .copyWith(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500)),
                                              ],
                                            ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
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
                    global.showOnlyLoaderDialog(
                        Get.context); // Show loader immediately

                    try {
                      // <--- START OF THE CRITICAL TRY BLOCK

                      // 1. Calculate amount (simplified and safer for double parsing)
                      // Ensure gst is parsed once and correctly
                      final double gstPercentage = double.parse(global
                          .getSystemFlagValue(global.systemFlagNameList.gst));
                      final double totalAmountWithGst =
                          widget.amount + (widget.amount * gstPercentage / 100);
                      final double amountToSend = double.parse(
                          totalAmountWithGst.toStringAsFixed(
                              2)); // Ensure 2 decimal places and parse to double

                      // 2. Calculate cashback (simplified and safer)
                      // Assuming widget.cashback is the percentage (e.g., 10 for 10%)
                      int cashbackToSend = 0;
                      if (widget.cashback != 0) {
                        // Take the integer part of the base amount for cashback calculation if specified
                        final int baseAmountInt = widget.amount.toInt();
                        final double rawCashbackAmount =
                            baseAmountInt * (widget.cashback! / 100.0);
                        cashbackToSend = rawCashbackAmount
                            .round()
                            .toInt(); // Round to nearest integer for cashback
                      }
                      // If widget.cashback is already the absolute amount, simply:
                      // int cashbackToSend = widget.cashback.toInt();

                      final response = await apiHelper.addAmountInWallet(
                        amount: amountToSend,
                        cashback: cashbackToSend,
                        userId: global.user.id!,
                      );

                      global
                          .hideLoader(); // Hide loader once API response is received

                      if (response['status'] == 200) {
                        print(
                            "jkasdjksa"); // Debug print - good for immediate feedback
                        log("API Response: $response"); // Log the full response

                        // Ensure 'url' exists and is a String before navigating
                        if (response.containsKey('url') &&
                            response['url'] is String &&
                            (response['url'] as String).isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentScreen(
                                // url: response['url'],
                                amount:
                                    '${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${((widget.amount + int.parse(widget.cashback.toString()) / 100).toStringAsFixed(2))}',
                              ),
                            ),
                          );
                        } else {
                          // Handle case where URL is missing or invalid in a 200 response
                          Get.snackbar(
                              'Error', 'Payment URL missing from response.',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors
                                  .orange, // Use a different color for this specific error
                              colorText: Colors.white);
                          log("Payment URL missing or invalid: ${response['url']}");
                        }
                      } else {
                        // API returned a non-200 status, indicating a server-side error
                        Get.snackbar(
                            'Error',
                            response['message'] ??
                                'Payment failed. Please try again.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white);
                        log("API Error (Status ${response['status']}): ${response['message']}");
                      }
                    } catch (e) {
                      // <--- CATCH BLOCK FOR EXCEPTIONS (e.g., network errors, parsing errors)
                      global.hideLoader(); // Always hide loader on error
                      Get.snackbar('Error', 'An unexpected error occurred: $e',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white);
                      log("Exception during payment process: $e"); // Log the exception for debugging
                    }
                  }, // <--- END OF onPressed
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
