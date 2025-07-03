import 'package:AstrowayCustomer/apiManager/apiServices.dart';
import 'package:AstrowayCustomer/controllers/proKerela/LoveCompatibilityController.dart';
import 'package:AstrowayCustomer/views/proKerela/LoveCompatibilityResultScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../utils/global.dart' as global;

class LoveCompatibilityInputScreen extends StatelessWidget {
  final LoveCompatibilityController controller = Get.put(
    LoveCompatibilityController(apiService: ApiService()),
  );

  // Cosmic color palette
  static const Color cosmicBlue = Color(0xFF1A2B42);
  static const Color celestialGold = Color(0xFFD4AF37);
  static const Color stardustWhite = Color(0xFFF0F0F0);
  static const Color lunarSilver = Color(0xFFC0C0C0);
  static const Color darkAccent = Color(0xFF2C3E50);
  static const Color mediumAccent = Color(0xFF34495E);
  static const Color warningRed = Color(0xFFE57373);

  final List<String> zodiacSigns = [
    'Aries',
    'Taurus',
    'Gemini',
    'Cancer',
    'Leo',
    'Virgo',
    'Libra',
    'Scorpio',
    'Sagittarius',
    'Capricorn',
    'Aquarius',
    'Pisces',
  ];
  final Rx<String?> selectedSignOne = Rx<String?>(null);
  final Rx<String?> selectedSignTwo = Rx<String?>(null);
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  LoveCompatibilityInputScreen({Key? key}) : super(key: key);

  Future<void> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: celestialGold,
              onPrimary: cosmicBlue,
              surface: stardustWhite,
              onSurface: cosmicBlue,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: cosmicBlue,
              ),
            ),
            dialogTheme: DialogTheme(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: const BorderSide(color: celestialGold, width: 1.5),
              ),
              backgroundColor: stardustWhite,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      selectedDate.value = pickedDate;
    }
  }

  Widget _buildThemedDropdown({
    required Rx<String?> selectedValue,
    required List<String> items,
    required String hintText,
    required IconData icon,
  }) {
    return Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: cosmicBlue.withOpacity(0.7),
            border:
                Border.all(color: celestialGold.withOpacity(0.6), width: 1.2),
          ),
          child: DropdownButtonFormField<String>(
            dropdownColor: cosmicBlue,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: celestialGold),
              labelText: hintText,
              labelStyle: GoogleFonts.poppins(color: lunarSilver),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
            ),
            style: GoogleFonts.poppins(color: stardustWhite, fontSize: 16),
            value: selectedValue.value,
            items: items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value,
                    style: GoogleFonts.poppins(color: stardustWhite)),
              );
            }).toList(),
            onChanged: (String? newValue) {
              selectedValue.value = newValue;
            },
          ),
        ));
  }

  void _showSnackbar(String title, String message, Color backgroundColor) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: backgroundColor.withOpacity(0.9),
      colorText: stardustWhite,
      margin: const EdgeInsets.all(15),
      borderRadius: 12,
      icon: Icon(
          backgroundColor == warningRed
              ? Icons.error_outline
              : Icons.check_circle_outline,
          color: stardustWhite,
          size: 28),
      snackStyle: SnackStyle.FLOATING,
      duration: const Duration(seconds: 3),
    );
  }

  void _submit() async {
    const double compatibilityPrice = 599.0;

    final signOne = selectedSignOne.value;
    final signTwo = selectedSignTwo.value;

    if (signOne == null || signTwo == null) {
      _showSnackbar('Error', 'Please select both zodiac signs', warningRed);
      return;
    }

    // --- Wallet Balance Check ---
    if (global.user.walletAmount == null ||
        global.user.walletAmount! < compatibilityPrice) {
      final shortfall = compatibilityPrice - (global.user.walletAmount ?? 0);
      _showSnackbar(
        'Insufficient Balance',
        'You need ₹${shortfall.toStringAsFixed(2)} more to access Love Compatibility. Please recharge your wallet.',
        warningRed,
      );
      return;
    }

    // --- Deduct Amount ---
    global.user.walletAmount = global.user.walletAmount! - compatibilityPrice;
    _showSnackbar(
      'Payment Successful',
      '₹${compatibilityPrice.toStringAsFixed(2)} deducted from your wallet for Love Compatibility.',
      celestialGold,
    );

    // --- API Call ---
    final result = await controller.fetchCompatibility(
      signOne: signOne,
      signTwo: signTwo,
      dateTime: selectedDate.value,
    );

    if (result != null) {
      Get.to(() => LoveCompatibilityResultScreen(
            compatibility: result.compatibility ?? 'N/A',
            report: result.report ?? 'No report available',
          ));
    } else {
      _showSnackbar('Error', 'Failed to fetch compatibility', warningRed);
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
          'Love Compatibility',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: stardustWhite,
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: stardustWhite, size: 28),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [cosmicBlue, darkAccent, mediumAccent],
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
                      color: celestialGold.withOpacity(0.8), width: 2),
                ),
                color: cosmicBlue.withOpacity(0.85),
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Find Your Cosmic Connection",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: celestialGold,
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
                      _buildThemedDropdown(
                        selectedValue: selectedSignOne,
                        items: zodiacSigns,
                        hintText: "First Zodiac Sign",
                        icon: Icons.star,
                      ),
                      const SizedBox(height: 20),
                      _buildThemedDropdown(
                        selectedValue: selectedSignTwo,
                        items: zodiacSigns,
                        hintText: "Second Zodiac Sign",
                        icon: Icons.star,
                      ),
                      const SizedBox(height: 20),
                      Obx(() => Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: celestialGold.withOpacity(0.6),
                                  width: 1.2),
                              color: cosmicBlue.withOpacity(0.7),
                            ),
                            child: ListTile(
                              title: Text(
                                'Date: ${DateFormat("MMM dd, yyyy").format(selectedDate.value)}',
                                style:
                                    GoogleFonts.poppins(color: stardustWhite),
                              ),
                              leading: Icon(Icons.calendar_today,
                                  color: celestialGold),
                              trailing: Icon(Icons.edit, color: lunarSilver),
                              onTap: () => _selectDate(context),
                            ),
                          )),
                      const SizedBox(height: 30),
                      Obx(() => SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  controller.isLoading.value ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: celestialGold,
                                foregroundColor: cosmicBlue,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 8,
                                shadowColor: celestialGold.withOpacity(0.5),
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
                                            color: cosmicBlue,
                                          ),
                                        ),
                                        const SizedBox(width: 15),
                                        Text(
                                          "Calculating...",
                                          style: GoogleFonts.poppins(
                                              fontSize: 18, color: cosmicBlue),
                                        ),
                                      ],
                                    )
                                  : Text(
                                      "Check Compatibility",
                                      style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: cosmicBlue),
                                    ),
                            ),
                          )),
                      const SizedBox(height: 16),
                      Obx(() => controller.errorMessage.value.isNotEmpty
                          ? Text(
                              controller.errorMessage.value,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                  color: warningRed, fontSize: 16),
                            )
                          : const SizedBox()),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "Discover how the stars align for your relationship",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: lunarSilver,
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
