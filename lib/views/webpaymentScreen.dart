// ignore_for_file: must_be_immutable

import 'dart:developer';

import 'package:AstrowayCustomer/controllers/history_controller.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../utils/global.dart' as global;
import '../widget/commonAppbar.dart';
import 'bottomNavigationBarScreen.dart';

class PaymentScreen extends StatefulWidget {
  final String amount; // Amount passed to this screen
  final int? cashback; // Cashback passed to this screen (if any)

  PaymentScreen({Key? key, required this.amount, this.cashback})
      : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final historyController = Get.find<HistoryController>();
  late Razorpay _razorpay;

  double _parsedAmount = 0.0; // Store the parsed and validated amount

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    // --- Validate and parse the amount once when the screen initializes ---
    try {
      String cleaned = widget.amount.replaceAll(RegExp(r'[^\d.]'), '');
      _parsedAmount = double.parse(cleaned);

      if (_parsedAmount <= 0) {
        throw Exception("Amount must be greater than 0.");
      }
    } catch (e) {
      // If amount parsing fails or is invalid, show an error and pop the screen
      Fluttertoast.showToast(
        msg: "Error: Invalid amount provided for payment.",
        backgroundColor: Colors.red,
      );
      log("PaymentScreen: Amount parsing error in initState: $e for amount: ${widget.amount}");
      // Use addPostFrameCallback to ensure UI is built before navigating back
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back(); // Navigate back if the initial amount is invalid
      });
    }
  }

  @override
  void dispose() {
    _razorpay.clear(); // Clear Razorpay listeners to prevent memory leaks
    super.dispose();
  }

  // Opens the Razorpay checkout interface
  void openRazorpayCheckout() {
    // Check if the parsed amount is valid before opening checkout
    if (_parsedAmount <= 0) {
      Fluttertoast.showToast(
        msg: "Cannot process payment with zero or negative amount.",
        backgroundColor: Colors.red,
      );
      return;
    }

    var options = {
      'key': 'rzp_live_OgYPmBDL7Q7dZS', // Your Razorpay Live Key
      'amount': (_parsedAmount * 100).toInt(), // Razorpay takes amount in paise
      'name': 'Astroway',
      'description': 'Wallet Recharge',
      'prefill': {
        'contact': global.splashController.currentUser?.contactNo ?? '',
        'email': global.splashController.currentUser?.email ?? '',
      },
      // You can add 'order_id' here if you pre-create orders on your backend
      // 'order_id': 'order_xxxxxxxxxxxxxx', // Optional: If you pre-create orders
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      log('Razorpay Error opening checkout: $e');
      Fluttertoast.showToast(
        msg: "Unable to open payment gateway. Please try again.",
        backgroundColor: Colors.red,
      );
    }
  }

  // Handler for successful Razorpay payments
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    log("--------------------------------------------------");
    log("Razorpay Payment SUCCESS:");
    log("  Payment ID: ${response.paymentId}");
    log("  Order ID: ${response.orderId}");
    log("  Signature: ${response.signature}");
    log("  Amount paid (from client-side context): $_parsedAmount");
    log("--------------------------------------------------");

    // Show a toast indicating success and that wallet update is pending backend processing
    Fluttertoast.showToast(
      msg: "Payment Successful! Wallet will be updated shortly.",
      backgroundColor: Colors.blue, // Use blue to indicate an ongoing process
      toastLength: Toast.LENGTH_LONG, // Give user more time to read
    );

    // --- CRITICAL: Refresh user data from backend AFTER Razorpay success ---
    // This assumes your backend has a webhook configured with Razorpay
    // that will update the wallet in the database.
    // We add a small delay to give the backend webhook a chance to process.
    await Future.delayed(Duration(
        seconds: 3)); // Adjust delay as needed based on backend webhook speed

    try {
      log("Attempting to refresh user data from backend via SplashController...");
      await global.splashController.getCurrentUserData();
      log("User data refreshed. New wallet amount: ${global.splashController.currentUser?.walletAmount}");

      // Optionally, refresh history if it's relevant to the wallet update
      await historyController.getChatHistory(global.currentUserId!, false);

      Fluttertoast.showToast(
        msg: "Wallet updated successfully!", // Final confirmation toast
        backgroundColor: Colors.green,
        toastLength: Toast.LENGTH_SHORT,
      );
    } catch (e) {
      log("Error refreshing user data after payment success: $e");
      Fluttertoast.showToast(
        msg:
            "Wallet update failed! Please contact support with payment ID: ${response.paymentId}",
        backgroundColor: Colors.orange, // Orange for a warning/partial success
        toastLength: Toast.LENGTH_LONG,
      );
    } finally {
      // Navigate back to the home/wallet screen regardless of refresh outcome
      // This ensures the user isn't stuck on the payment screen.
      Get.off(() => BottomNavigationBarScreen(index: 0));
    }
  }

  // Handler for failed Razorpay payments
  void _handlePaymentError(PaymentFailureResponse response) {
    log("--------------------------------------------------");
    log("Razorpay Payment FAILED:");
    log("  Code: ${response.code}");
    log("  Message: ${response.message}");

    log("--------------------------------------------------");

    Fluttertoast.showToast(
      msg: "Payment Failed: ${response.message ?? 'Unknown error'}",
      backgroundColor: Colors.red,
      toastLength: Toast.LENGTH_LONG,
    );
    // Navigate back to the home/wallet screen
    Get.off(() => BottomNavigationBarScreen(index: 0));
  }

  // Handler for external wallet (e.g., Google Pay, PhonePe)
  void _handleExternalWallet(ExternalWalletResponse response) {
    log("External Wallet selected: ${response.walletName}");
    Fluttertoast.showToast(
      msg: "External Wallet: ${response.walletName}",
      backgroundColor: Colors.grey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: CommonAppBar(title: 'Payment Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                openRazorpayCheckout(); // Call the method without passing amount again
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Get.theme.primaryColor, // Apply app's primary color
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Pay with Razorpay',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Fluttertoast.showToast(msg: "PayPal integration coming soon.");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey, // Different color for PayPal
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Pay with PayPal',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
