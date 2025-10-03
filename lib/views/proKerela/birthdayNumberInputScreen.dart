import 'package:AstrowayCustomer/fastApi/fastApiServices.dart';
import 'package:AstrowayCustomer/views/proKerela/birthdayNumberResultScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../apiManager/apiServices.dart';
import '../../controllers/proKerela/birthdayNumberController.dart';
import '../../model/fastApiModel/currentUserWalletModel.dart';
import '../../utils/global.dart' as global;

class BirthdayNumberInputScreen extends StatefulWidget {
  BirthdayNumberInputScreen({Key? key}) : super(key: key);

  static const Color cosmicBlue = Color(0xFF1A2B42);
  static const Color celestialGold = Color(0xFFD4AF37);
  static const Color stardustWhite = Color(0xFFF0F0F0);
  static const Color lunarSilver = Color(0xFFC0C0C0);
  static const Color darkAccent = Color(0xFF2C3E50);
  static const Color mediumAccent = Color(0xFF34495E);
  static const Color warningRed = Color(0xFFE57373);

  static const double birthdayNumberPrice = 100.0;

  @override
  State<BirthdayNumberInputScreen> createState() => _BirthdayNumberInputScreenState();
}

class _BirthdayNumberInputScreenState extends State<BirthdayNumberInputScreen> {
  final BirthdayNumberController controller = Get.put(
    BirthdayNumberController(apiService: ApiService()),
  );

  final Rx<DateTime> selectedDate = DateTime.now().obs;
  CurrentUserWalletModel? _wallet;

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: BirthdayNumberInputScreen.celestialGold,
              onPrimary: BirthdayNumberInputScreen.cosmicBlue,
              surface: BirthdayNumberInputScreen.stardustWhite,
              onSurface: BirthdayNumberInputScreen.cosmicBlue,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: BirthdayNumberInputScreen.cosmicBlue),
            ),
            dialogTheme: DialogTheme(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: const BorderSide(color: BirthdayNumberInputScreen.celestialGold, width: 1.5),
              ),
              backgroundColor: BirthdayNumberInputScreen.stardustWhite,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      selectedDate.value = picked;
    }
  }

  void _showSnackbar(String title, String message, Color backgroundColor) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: backgroundColor.withOpacity(0.9),
      colorText: BirthdayNumberInputScreen.stardustWhite,
      margin: const EdgeInsets.all(15),
      borderRadius: 12,
      icon: Icon(
        backgroundColor == BirthdayNumberInputScreen.warningRed
            ? Icons.error_outline
            : Icons.check_circle_outline,
        color: BirthdayNumberInputScreen.stardustWhite,
        size: 28,
      ),
      snackStyle: SnackStyle.FLOATING,
      duration: const Duration(seconds: 3),
    );
  }

  void _submit() async {
    const int birthdayNumberPrice = 599;

    try {
      // 1️⃣ Fetch wallet balance
      final wallet = await FastAPIServices().fetchCurrentWallet();
      if (wallet == null) {
        _showSnackbar(
          'Wallet Error',
          'Unable to fetch wallet balance. Please try again.',
          BirthdayNumberInputScreen.warningRed,
        );
        return;
      }

      // 2️⃣ Check balance
      if (wallet.amount < birthdayNumberPrice) {
        final shortfall = birthdayNumberPrice - wallet.amount;
        _showSnackbar(
          'Insufficient Balance',
          'You need ₹${shortfall.toStringAsFixed(2)} more to access Birthday Number. Please recharge your wallet.',
          BirthdayNumberInputScreen.warningRed,
        );
        return;
      }

      // 3️⃣ Deduct using debit API
      final updatedWallet =
      await FastAPIServices().debitWallet(birthdayNumberPrice);

      if (updatedWallet == null) {
        _showSnackbar(
          'Payment Failed',
          'Could not deduct wallet. Try again.',
          BirthdayNumberInputScreen.warningRed,
        );
        return;
      }

      // 4️⃣ Payment success
      _showSnackbar(
        'Payment Successful',
        '₹${birthdayNumberPrice.toStringAsFixed(2)} deducted from your wallet for Birthday Number.',
        BirthdayNumberInputScreen.celestialGold,
      );

      setState(() {
        _wallet = updatedWallet;
      });

      // 5️⃣ API Call → Birthday Number
      final result = await controller.fetchBirthdayNumber(
        dateTime: selectedDate.value,
      );

      if (result != null) {
        Get.to(() => BirthdayNumberResultScreen(
          name: result.name ?? 'Birthday Number',
          number: result.number?.toString() ?? '0',
          description: result.description ?? 'No description available',
        ));
      } else {
        _showSnackbar(
          'Error',
          controller.errorMessage.value.isNotEmpty
              ? controller.errorMessage.value
              : 'Failed to calculate birthday number',
          BirthdayNumberInputScreen.warningRed,
        );
      }
    } catch (e) {
      _showSnackbar('Unexpected Error', 'Please try again.', BirthdayNumberInputScreen.warningRed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding =
        MediaQuery.of(context).padding.top + AppBar().preferredSize.height + 25;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Birthday Number',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: BirthdayNumberInputScreen.stardustWhite,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: BirthdayNumberInputScreen.stardustWhite, size: 28),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [BirthdayNumberInputScreen.cosmicBlue, BirthdayNumberInputScreen.darkAccent, BirthdayNumberInputScreen.mediumAccent],
            stops: [0.1, 0.5, 0.9],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 25,
            right: 25,
            bottom: 25,
            top: topPadding,
          ),
          child: Column(
            children: [
              Card(
                elevation: 12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                      color: BirthdayNumberInputScreen.celestialGold.withOpacity(0.8), width: 2),
                ),
                color: BirthdayNumberInputScreen.cosmicBlue.withOpacity(0.85),
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Unlock Your Life Path Number",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: BirthdayNumberInputScreen.celestialGold,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Obx(() => Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: BirthdayNumberInputScreen.celestialGold.withOpacity(0.6),
                                  width: 1.2),
                              color: BirthdayNumberInputScreen.cosmicBlue.withOpacity(0.7),
                            ),
                            child: ListTile(
                              title: Text(
                                'Birth Date: ${DateFormat("MMM dd, yyyy").format(selectedDate.value)}',
                                style:
                                    GoogleFonts.poppins(color: BirthdayNumberInputScreen.stardustWhite),
                              ),
                              leading: Icon(Icons.calendar_today,
                                  color: BirthdayNumberInputScreen.celestialGold),
                              trailing: Icon(Icons.edit, color: BirthdayNumberInputScreen.lunarSilver),
                              onTap: () => _pickDate(context),
                            ),
                          )),
                      const SizedBox(height: 30),
                      Obx(() => SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  controller.isLoading.value ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: BirthdayNumberInputScreen.celestialGold,
                                foregroundColor: BirthdayNumberInputScreen.cosmicBlue,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 8,
                                shadowColor: BirthdayNumberInputScreen.celestialGold.withOpacity(0.5),
                              ),
                              child: controller.isLoading.value
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 3,
                                            color: BirthdayNumberInputScreen.cosmicBlue,
                                          ),
                                        ),
                                        const SizedBox(width: 15),
                                        Text(
                                          "Calculating...",
                                          style: GoogleFonts.poppins(
                                              fontSize: 18, color: BirthdayNumberInputScreen.cosmicBlue),
                                        ),
                                      ],
                                    )
                                  : Column(
                                    children: [
                                      Text(
                                          "Calculate Your Number",
                                          style: GoogleFonts.poppins(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: BirthdayNumberInputScreen.cosmicBlue),
                                        ),
                                      Text(
                                        "₹100 + GST",
                                        style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: BirthdayNumberInputScreen.cosmicBlue),
                                      ),
                                    ],
                                  ),
                            ),
                          )),
                      const SizedBox(height: 16),
                      Obx(() => controller.errorMessage.value.isNotEmpty
                          ? Text(
                              controller.errorMessage.value,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                  color: BirthdayNumberInputScreen.warningRed, fontSize: 16),
                            )
                          : const SizedBox()),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "Discover the insights your birth date reveals.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: BirthdayNumberInputScreen.lunarSilver,
                  fontStyle: FontStyle.italic,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
