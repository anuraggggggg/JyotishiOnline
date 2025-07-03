import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/proKerela/daily_prediction_controller.dart';
import 'package:intl/intl.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;

class DailyPredictionInputScreen extends StatelessWidget {
  final DailyPredictionController controller =
      Get.put(DailyPredictionController());

  final List<Map<String, String>> zodiacSigns = const [
    {'value': 'aries', 'label': 'Aries - The Ram'},
    {'value': 'taurus', 'label': 'Taurus - The Bull'},
    {'value': 'gemini', 'label': 'Gemini - The Twins'},
    {'value': 'cancer', 'label': 'Cancer - The Crab'},
    {'value': 'leo', 'label': 'Leo - The Lion'},
    {'value': 'virgo', 'label': 'Virgo - The Maiden'},
    {'value': 'libra', 'label': 'Libra - The Scales'},
    {'value': 'scorpio', 'label': 'Scorpio - The Scorpion'},
    {'value': 'sagittarius', 'label': 'Sagittarius - The Archer'},
    {'value': 'capricorn', 'label': 'Capricorn - The Goat'},
    {'value': 'aquarius', 'label': 'Aquarius - The Water Bearer'},
    {'value': 'pisces', 'label': 'Pisces - The Fish'},
  ];

  static const Color cosmicBlue = Color(0xFF1A2B42);
  static const Color celestialGold = Color(0xFFD4AF37);
  static const Color stardustWhite = Color(0xFFF0F0F0);
  static const Color smokyGrey = Color(0xFF4A4A4A);
  static const Color lunarSilver = Color(0xFFC0C0C0);
  static const Color darkAccent = Color(0xFF2C3E50);
  static const Color mediumAccent = Color(0xFF34495E);
  static const Color warningRed = Color(0xFFE57373);

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
      barBlur: 5,
    );
  }

  Widget _buildThemedDropdownFormField<T>({
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required String labelText,
    required IconData icon,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      style: const TextStyle(
        color: stardustWhite,
        fontSize: 16,
        overflow: TextOverflow.ellipsis,
      ),
      icon: const Icon(Icons.arrow_drop_down, color: celestialGold, size: 28),
      // Ensure the dropdown menu background is dark blue
      dropdownColor:
          cosmicBlue.withOpacity(0.95), // This should already be dark blue
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(
          color:
              stardustWhite, // Changed from lunarSilver for better visibility
          fontWeight: FontWeight.w500,
          fontSize: 16,
          overflow: TextOverflow.ellipsis,
        ),
        prefixIcon: Icon(icon, color: celestialGold.withOpacity(0.9), size: 24),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        isDense: true,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: celestialGold.withOpacity(0.6), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: celestialGold, width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: warningRed, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: warningRed, width: 2.5),
        ),
        filled: true,
        fillColor: cosmicBlue.withOpacity(0.7),
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding =
        MediaQuery.of(context).padding.top + AppBar().preferredSize.height + 25;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Daily Cosmic Insight',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: stardustWhite,
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: stardustWhite, size: 28),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cosmicBlue,
              darkAccent,
              mediumAccent,
            ],
            stops: [0.1, 0.5, 0.9],
          ),
        ),
        child: Padding(
          padding:
              EdgeInsets.only(left: 25, right: 25, bottom: 25, top: topPadding),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                    side: BorderSide(
                        color: celestialGold.withOpacity(0.8), width: 2),
                  ),
                  color: cosmicBlue.withOpacity(0.85),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Your Daily Horoscope',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: celestialGold,
                              letterSpacing: 1.5,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 5,
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Obx(() => _buildThemedDropdownFormField<String>(
                              value: controller.selectedSign.value.isNotEmpty
                                  ? controller.selectedSign.value
                                  : null,
                              labelText: 'Select Zodiac Sign',
                              icon: Icons.auto_awesome,
                              items: zodiacSigns.map((sign) {
                                return DropdownMenuItem(
                                  value: sign['value'],
                                  child: Text(
                                    sign['label']!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color:
                                          stardustWhite, // <--- ADDED: Explicitly set text color for menu items
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                controller.selectedSign.value = value ?? '';
                              },
                            )),
                        const SizedBox(height: 25),
                        Obx(() => Row(
                              children: [
                                Icon(Icons.calendar_month,
                                    color: celestialGold.withOpacity(0.9),
                                    size: 24),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Date: ${DateFormat('yyyy-MM-dd').format(controller.selectedDate.value)}",
                                    style: const TextStyle(
                                      color: stardustWhite,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate:
                                          controller.selectedDate.value,
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime.now()
                                          .add(const Duration(days: 7)),
                                      builder: (context, child) {
                                        return Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme:
                                                const ColorScheme.light(
                                              primary: celestialGold,
                                              onPrimary: cosmicBlue,
                                              surface: stardustWhite,
                                              onSurface: cosmicBlue,
                                            ),
                                            textButtonTheme:
                                                TextButtonThemeData(
                                              style: TextButton.styleFrom(
                                                foregroundColor: cosmicBlue,
                                              ),
                                            ),
                                            dialogTheme: DialogTheme(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                side: const BorderSide(
                                                    color: celestialGold,
                                                    width: 1.5),
                                              ),
                                              backgroundColor: stardustWhite,
                                            ),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );
                                    if (picked != null) {
                                      controller.selectedDate.value = picked;
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        celestialGold.withOpacity(0.9),
                                    foregroundColor: cosmicBlue,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 3,
                                    minimumSize: const Size(0, 36),
                                  ),
                                  child: const Text(
                                    'Pick Date',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                )
                              ],
                            )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Obx(() => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          if (controller.selectedSign.value.isEmpty) {
                            _showSnackbar('Error',
                                'Please select a zodiac sign', warningRed);
                            return;
                          }

                          // --- Start: Wallet Deduction Logic ---
                          const double predictionPrice = 100.0;

                          // Replace this with your actual global user wallet reference
                          if (global.user.walletAmount == null ||
                              global.user.walletAmount! < predictionPrice) {
                            final shortfall = predictionPrice -
                                (global.user.walletAmount ?? 0);
                            _showSnackbar(
                              'Insufficient Balance',
                              'You need ₹${shortfall.toStringAsFixed(2)} more to access Daily Prediction. Please recharge your wallet.',
                              warningRed,
                            );
                            return;
                          }

                          // Deduct from wallet
                          global.user.walletAmount =
                              global.user.walletAmount! - predictionPrice;
                          _showSnackbar(
                            'Payment Successful',
                            '₹$predictionPrice deducted from your wallet for Daily Prediction.',
                            celestialGold,
                          );
                          await Future.delayed(
                              const Duration(milliseconds: 300)); // brief delay
                          // --- End: Wallet Deduction Logic ---

                          controller.fetchPrediction();
                        },
                        icon: controller.isLoading.value
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: cosmicBlue,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Icon(Icons.stars,
                                color: cosmicBlue, size: 28),
                        label: controller.isLoading.value
                            ? const Text('Conjuring Insight...',
                                style:
                                    TextStyle(color: cosmicBlue, fontSize: 18))
                            : const Text(
                                'Get Daily Prediction',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: cosmicBlue,
                                ),
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: celestialGold,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 8,
                          shadowColor: celestialGold.withOpacity(0.5),
                        ),
                      ),
                    )),
                const SizedBox(height: 20),
                Obx(() => controller.error.value.isNotEmpty
                    ? Card(
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(horizontal: 0),
                        color: warningRed.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: warningRed, width: 1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: warningRed, size: 28),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  controller.error.value,
                                  style: const TextStyle(
                                      color: stardustWhite, fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
