import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/proKerela/daily_prediction_controller.dart';
import '../../fastApi/fastApiServices.dart';
import '../../model/fastApiModel/currentUserWalletModel.dart';

class DailyPredictionInputScreen extends StatefulWidget {
  const DailyPredictionInputScreen({Key? key}) : super(key: key);

  @override
  State<DailyPredictionInputScreen> createState() =>
      _DailyPredictionInputScreenState();
}

class _DailyPredictionInputScreenState
    extends State<DailyPredictionInputScreen> {
  final DailyPredictionController controller =
  Get.put(DailyPredictionController());

  CurrentUserWalletModel? _wallet;

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
        size: 28,
      ),
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
      dropdownColor: cosmicBlue.withOpacity(0.95),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(
          color: stardustWhite,
          fontWeight: FontWeight.w500,
          fontSize: 16,
          overflow: TextOverflow.ellipsis,
        ),
        prefixIcon: Icon(icon, color: celestialGold, size: 24),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: celestialGold.withOpacity(0.6), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: celestialGold, width: 2.5),
        ),
        filled: true,
        fillColor: cosmicBlue.withOpacity(0.7),
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  Future<void> _handlePrediction() async {
    if (controller.selectedSign.value.isEmpty) {
      _showSnackbar('Error', 'Please select a zodiac sign', warningRed);
      return;
    }

    const int predictionPrice = 100;
    controller.isLoading.value = true;

    try {
      // 1️⃣ Fetch wallet balance
      final wallet = await FastAPIServices().fetchCurrentWallet();
      if (wallet == null) {
        _showSnackbar('Wallet Error', 'Unable to fetch wallet balance.', warningRed);
        controller.isLoading.value = false;
        return;
      }

      // 2️⃣ Check balance
      if (wallet.amount < predictionPrice) {
        final shortfall = predictionPrice - wallet.amount;
        _showSnackbar(
          'Insufficient Balance',
          'You need ₹${shortfall.toStringAsFixed(2)} more to access Daily Prediction.',
          warningRed,
        );
        controller.isLoading.value = false;
        return;
      }

      // 3️⃣ Deduct using debit API
      final updatedWallet = await FastAPIServices().debitWallet(predictionPrice);
      if (updatedWallet == null) {
        _showSnackbar('Payment Failed', 'Could not deduct wallet.', warningRed);
        controller.isLoading.value = false;
        return;
      }

      // 4️⃣ Success
      _showSnackbar(
        'Payment Successful',
        '₹${predictionPrice.toStringAsFixed(2)} deducted for Daily Prediction.',
        celestialGold,
      );

      setState(() => _wallet = updatedWallet);

      await Future.delayed(const Duration(milliseconds: 300));

      // 5️⃣ Fetch prediction
      controller.fetchPrediction();
    } catch (e) {
      print('Daily prediction error: $e');
      _showSnackbar('Unexpected Error', 'Please try again.', warningRed);
    } finally {
      controller.isLoading.value = false;
    }
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
        child: Padding(
          padding: EdgeInsets.only(left: 25, right: 25, bottom: 25, top: topPadding),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 🌟 Restored Horoscope Card 🌟
                Card(
                  elevation: 12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                    side: BorderSide(color: celestialGold.withOpacity(0.8), width: 2),
                  ),
                  color: cosmicBlue.withOpacity(0.85),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          'Your Daily Horoscope',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: celestialGold,
                          ),
                        ),
                        const SizedBox(height: 25),

                        // Dropdown
                        Obx(() => _buildThemedDropdownFormField<String>(
                          value: controller.selectedSign.value.isNotEmpty
                              ? controller.selectedSign.value
                              : null,
                          items: zodiacSigns.map((sign) {
                            return DropdownMenuItem(
                              value: sign['value'],
                              child: Text(sign['label']!,
                                  style: const TextStyle(color: stardustWhite)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            controller.selectedSign.value = value ?? '';
                          },
                          labelText: 'Select Zodiac Sign',
                          icon: Icons.auto_awesome,
                        )),
                        const SizedBox(height: 20),

                        // Date picker
                        Obx(() => Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                color: celestialGold, size: 24),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Date: ${DateFormat('yyyy-MM-dd').format(controller.selectedDate.value)}",
                                style: const TextStyle(
                                    color: stardustWhite, fontSize: 16),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: controller.selectedDate.value,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime.now().add(const Duration(days: 7)),
                                );
                                if (picked != null) {
                                  controller.selectedDate.value = picked;
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: celestialGold,
                                foregroundColor: cosmicBlue,
                              ),
                              child: const Text('Pick Date'),
                            ),
                          ],
                        )),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Prediction button
                Obx(() => ElevatedButton.icon(
                  onPressed: _handlePrediction,
                  icon: controller.isLoading.value
                      ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: cosmicBlue,
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(cosmicBlue),
                    ),
                  )
                      : Icon(Icons.stars_rounded, color: cosmicBlue, size: 26),
                  label: controller.isLoading.value
                      ? Text(
                    'Conjuring Insight...',
                    style: TextStyle(
                      color: cosmicBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                      : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Get Daily Prediction',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: cosmicBlue,
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: cosmicBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '₹100 + GST',
                          style: TextStyle(
                            fontSize: 12,
                            color: cosmicBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: celestialGold,
                    foregroundColor: cosmicBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: cosmicBlue.withOpacity(0.2), width: 1),
                    ),
                    elevation: 2,
                    shadowColor: cosmicBlue.withOpacity(0.2),
                  ),
                )),

                const SizedBox(height: 20),

                // Error card
                Obx(() => controller.error.value.isNotEmpty
                    ? Card(
                  color: warningRed.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: warningRed, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(controller.error.value,
                        style: const TextStyle(color: stardustWhite)),
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
