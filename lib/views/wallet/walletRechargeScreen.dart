import 'dart:convert';
import 'package:AstrowayCustomer/services/location_services.dart';
import 'package:http/http.dart' as http;
import 'package:AstrowayCustomer/fastApi/fastApiServices.dart';
import 'package:AstrowayCustomer/model/fastApiModel/currentUserWalletModel.dart';
import 'package:AstrowayCustomer/theme/appTheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

class RechargeWalletScreen extends StatefulWidget {
  @override
  State<RechargeWalletScreen> createState() => _RechargeWalletScreenState();
}

class _RechargeWalletScreenState extends State<RechargeWalletScreen> {
  Razorpay? _razorpay;
  int? _selectedAmount;
  CurrentUserWalletModel? _wallet;
  double? usdRate;
  bool isLoading = true;

  static const double gstRate = 0.18;

  final TextEditingController _customAmountController =
  TextEditingController();

  final List<int> amounts = [50, 100, 500, 1000, 1500, 2000];
  final List<double> usdAmounts = [0.6, 1.2, 6, 12, 18, 24];

  /// ================= GST CALCULATIONS =================

  double get gstAmount =>
      _selectedAmount != null ? _selectedAmount! * gstRate : 0;

  double get totalAmount =>
      _selectedAmount != null ? _selectedAmount! + gstAmount : 0;

  /// =====================================================

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();

    _razorpay?.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay?.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay?.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    try {
      final wallet = await FastAPIServices().fetchCurrentWallet();
      final rate = await _fetchUsdRate();

      if (!mounted) return;

      setState(() {
        _wallet = wallet;
        usdRate = rate;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading data: $e");
      setState(() => isLoading = false);
    }
  }

  Future<double> _fetchUsdRate() async {
    try {
      final response =
      await http.get(Uri.parse("https://open.er-api.com/v6/latest/INR"));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data["rates"]["USD"].toDouble();
      }
    } catch (e) {
      debugPrint("Rate API error: $e");
    }
    return 0.012;
  }

  /// ================= PAYMENT =================

  void _openCheckout() {
    if (_selectedAmount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select an amount")),
      );
      return;
    }

    var options = {
      'key': 'rzp_live_OgYPmBDL7Q7dZS',
      'amount': (totalAmount * 100).toInt(), // GST INCLUDED
      'name': 'Wallet Recharge',
      'description': 'Adding money to wallet (Incl. 18% GST)',
      'prefill': {
        'contact': '9876543210',
        'email': 'test@example.com',
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay?.open(options);
    } catch (e) {
      debugPrint("Razorpay Error: $e");
    }
  }

  /// PAYMENT SUCCESS
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (_selectedAmount != null) {
      try {
        final updatedWallet =
        await FastAPIServices().creditWallet(_selectedAmount!);

        setState(() => _wallet = updatedWallet);

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle,
                    color: Colors.green, size: 70),
                const SizedBox(height: 20),
                const Text(
                  "Payment Successful!",
                  style:
                  TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text("₹$_selectedAmount added to wallet"),
                const SizedBox(height: 10),
                Text("Txn: ${response.paymentId}",
                    style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: appYellow,
                      foregroundColor: textColor),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context, true);
                  },
                  child: const Text("OK"),
                )
              ],
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Wallet update failed")),
        );
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Payment Failed")));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("External Wallet Selected")));
  }

  @override
  void dispose() {
    _razorpay?.clear();
    _customAmountController.dispose();
    super.dispose();
  }

  /// ================= UI =================

  Widget _priceRow(String label, double value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        Text(
          LocationService.isIndianUser
              ? "₹${value.toStringAsFixed(2)}"
              : "\$${(value * usdRate!).toStringAsFixed(2)}",
          style:
          TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recharge Wallet",
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: appYellow,
        iconTheme: const IconThemeData(color: textColor),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          children: [
            /// HEADER
            Container(
              width: double.infinity,
              padding:
              const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
              decoration: const BoxDecoration(
                color: appYellow,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: Column(
                children: [
                  const Text("Current Wallet Balance",
                      style: TextStyle(color: textColor)),
                  const SizedBox(height: 10),

                  if (isLoading)
                    const CircularProgressIndicator(color: textColor)
                  else
                    Text(
                      LocationService.isIndianUser
                          ? "₹${_wallet?.amount ?? 0}"
                          : "\$${((_wallet?.amount ?? 0) * usdRate!)
                          .toStringAsFixed(2)}",
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: textColor),
                    ),

                  const SizedBox(height: 15),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.info_outline, color: textColor),
                        SizedBox(width: 8),
                        Expanded(
                            child: Text(
                                "Recharge now to enjoy seamless services",
                                style: TextStyle(color: textColor))),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// SELECT AMOUNT
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.6,
                    ),
                    itemCount: LocationService.isIndianUser
                        ? amounts.length
                        : usdAmounts.length,
                    itemBuilder: (_, i) {
                      num amount = LocationService.isIndianUser
                          ? amounts[i]
                          : usdAmounts[i];

                      bool selected = _selectedAmount == amount;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedAmount = amount.toInt();
                            _customAmountController.clear();
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: selected ? appYellow : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected
                                  ? appYellow
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              LocationService.isIndianUser
                                  ? "₹$amount"
                                  : "\$$amount",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: selected
                                    ? textColor
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  /// CUSTOM AMOUNT
                  TextField(
                    controller: _customAmountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Enter custom amount",
                      prefixIcon: LocationService.isIndianUser
                          ? const Icon(Icons.currency_rupee)
                          : const Icon(Icons.currency_exchange),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (v) =>
                        setState(() => _selectedAmount = int.tryParse(v)),
                  ),

                  const SizedBox(height: 20),

                  /// GST BREAKDOWN
                  if (_selectedAmount != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _priceRow("Amount", _selectedAmount!.toDouble()),
                          const SizedBox(height: 6),
                          _priceRow("GST (18%)", gstAmount),
                          const Divider(),
                          _priceRow("Total Payable", totalAmount,
                              bold: true),
                          const SizedBox(height: 8),
                          const Text(
                            "18% GST is applied as per government regulations. Wallet will be credited with base amount only.",
                            textAlign: TextAlign.center,
                            style:
                            TextStyle(fontSize: 12, color: Colors.grey),
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

      /// BUTTON
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: _openCheckout,
            style: ElevatedButton.styleFrom(
                backgroundColor: appYellow,
                minimumSize: const Size(double.infinity, 55)),
            child: const Text("Proceed to Payment",
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
