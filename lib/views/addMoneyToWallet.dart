import 'package:AstrowayCustomer/controllers/splashController.dart';
import 'package:AstrowayCustomer/controllers/walletController.dart';
import 'package:AstrowayCustomer/model/businessLayer/baseRoute.dart';
import 'package:AstrowayCustomer/utils/global.dart';
import 'package:AstrowayCustomer/views/paymentInformationScreen.dart'; // Ensure this path is correct for your PaymentScreen
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;
import 'package:responsive_sizer/responsive_sizer.dart';

import '../widget/commonAppbar.dart';

class AddmoneyToWallet extends BaseRoute {
  AddmoneyToWallet({a, o}) : super(a: a, o: o, r: 'AddMoneyToWallet');
  final WalletController walletController = Get.find<WalletController>();

  // Controller for the custom amount input field
  final TextEditingController _customAmountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: kIsWeb
          ? AppBar(leading: SizedBox())
          : PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: CommonAppBar(title: 'Add money to wallet', flagId: 1),
            ),
      body: SingleChildScrollView(
        child: GetBuilder<SplashController>(builder: (splash) {
          return Container(
            margin: kIsWeb
                ? EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.13)
                : const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Recharge Your Wallet Now',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: kIsWeb ? 18.sp : 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ).tr(),
                ),
                const SizedBox(height: 6),
                Text(
                  'Available Balance',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: kIsWeb ? 16.sp : null,
                    fontWeight: FontWeight.w500,
                  ),
                ).tr(),
                Text(
                  // Using .obs from SplashController for reactive update
                  '${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${splash.currentUser!.walletAmount!.toStringAsFixed(2)}',
                  style: Get.textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 12),
                GetBuilder<WalletController>(builder: (c) {
                  final amounts = walletController.paymentAmount;
                  if (amounts.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text('No amount options available.'),
                      ),
                    );
                  }

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: kIsWeb ? 4 : 2,
                      childAspectRatio: 3 / 1.5,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(8),
                    shrinkWrap: true,
                    itemCount: amounts.length,
                    itemBuilder: (context, index) {
                      final amount = amounts[index];

                      return GestureDetector(
                        onTap: () {
                          // Navigate to PaymentInformationScreen with predefined amount
                          Get.to(() => PaymentInformationScreen(
                                amount: double.parse(amount.amount.toString()),
                                cashback: amount.cashback,
                              ));
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${amount.amount}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (amount.cashback! > 0)
                                Container(
                                  decoration: BoxDecoration(
                                    color: Get.theme.primaryColor,
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(5),
                                      bottomRight: Radius.circular(5),
                                    ),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Recharge your wallet",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),

                // --- Start of Custom Payment Option ---
                const SizedBox(height: 20),
                Text(
                  'Or Enter Custom Amount',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: kIsWeb ? 16.sp : null,
                    fontWeight: FontWeight.w500,
                  ),
                ).tr(),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _customAmountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter amount',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixText:
                        '${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ',
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity, // Make button fill width
                  child: ElevatedButton(
                    onPressed: () {
                      _handleCustomAmountPayment(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Get.theme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Pay Custom Amount',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // --- End of Custom Payment Option ---

                const SizedBox(height: 20), // Add some spacing at the bottom
              ],
            ),
          );
        }),
      ),
    );
  }

  // Method to handle custom amount payment
  void _handleCustomAmountPayment(BuildContext context) {
    final String amountText = _customAmountController.text.trim();
    if (amountText.isEmpty) {
      Fluttertoast.showToast(
          msg: "Please enter an amount.", backgroundColor: Colors.red);
      return;
    }

    try {
      final double customAmount = double.parse(amountText);
      if (customAmount <= 0) {
        Fluttertoast.showToast(
            msg: "Amount must be greater than 0.", backgroundColor: Colors.red);
        return;
      }

      // Navigate to PaymentInformationScreen with the custom amount
      Get.to(() => PaymentInformationScreen(
            amount: customAmount,
            cashback:
                0, // No specific cashback for custom amounts, default to 0
          ));
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Invalid amount. Please enter a valid number.",
          backgroundColor: Colors.red);
    }
  }
}
