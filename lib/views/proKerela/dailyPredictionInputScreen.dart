import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/proKerela/daily_prediction_controller.dart';
import '../../fastApi/fastApiServices.dart';
import '../../model/fastApiModel/currentUserWalletModel.dart';

class DailyPredictionInputScreen extends StatefulWidget {
  final String serviceName;
  final double servicePrice;

  const DailyPredictionInputScreen({
    super.key,
    required this.serviceName,
    required this.servicePrice,
  });

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

  // 🎨 Colors
  static const Color cosmicBlue = Color(0xFF1A2B42);
  static const Color celestialGold = Color(0xFFD4AF37);
  static const Color stardustWhite = Color(0xFFF0F0F0);
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
    );
  }

  // 💳 PAYMENT + FETCH
  Future<void> _handlePrediction() async {
    if (controller.selectedSign.value.isEmpty) {
      _showSnackbar('Error', 'Please select a zodiac sign', warningRed);
      return;
    }

    final double price = widget.servicePrice;
    controller.isLoading.value = true;

    try {
      final wallet = await FastAPIServices().fetchCurrentWallet();
      if (wallet == null) {
        _showSnackbar('Wallet Error', 'Unable to fetch wallet balance', warningRed);
        return;
      }

      if (wallet.amount < price) {
        _showSnackbar(
          'Insufficient Balance',
          'You need ₹${(price - wallet.amount).toStringAsFixed(0)} more',
          warningRed,
        );
        return;
      }

      final updatedWallet =
      await FastAPIServices().debitWallet(price.toInt());

      if (updatedWallet == null) {
        _showSnackbar('Payment Failed', 'Wallet deduction failed', warningRed);
        return;
      }

      _showSnackbar(
        'Payment Successful',
        '₹${price.toStringAsFixed(0)} deducted',
        celestialGold,
      );

      _wallet = updatedWallet;
      controller.fetchPrediction();
    } finally {
      controller.isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.serviceName,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: stardustWhite,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [cosmicBlue, darkAccent, mediumAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: EdgeInsets.fromLTRB(
                  25,
                  MediaQuery.of(context).padding.top + kToolbarHeight + 20,
                  25,
                  25,
                ),
                child: Column(
                  children: [
                    Card(
                      color: cosmicBlue.withOpacity(0.85),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                        side:
                        BorderSide(color: celestialGold.withOpacity(0.7)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(
                              widget.serviceName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: celestialGold,
                              ),
                            ),
                            const SizedBox(height: 20),

                            /// ✅ FIXED DROPDOWN
                            Obx(() => DropdownButtonFormField<String>(
                              isExpanded: true, // 🔥 THIS FIXES THE OVERFLOW

                              value: controller.selectedSign.value.isNotEmpty
                                  ? controller.selectedSign.value
                                  : null,

                              dropdownColor: cosmicBlue.withOpacity(0.95),

                              icon: const Icon(
                                Icons.arrow_drop_down,
                                color: celestialGold,
                              ),

                              decoration: InputDecoration(
                                labelText: 'Select Zodiac Sign',
                                labelStyle: const TextStyle(color: stardustWhite),

                                prefixIcon: const Icon(
                                  Icons.auto_awesome,
                                  color: celestialGold,
                                ),

                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 12,
                                ),

                                filled: true,
                                fillColor: cosmicBlue.withOpacity(0.7),

                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: celestialGold.withOpacity(0.6),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: celestialGold,
                                    width: 2,
                                  ),
                                ),
                              ),

                              items: zodiacSigns.map((e) {
                                return DropdownMenuItem<String>(
                                  value: e['value'],
                                  child: Text(
                                    e['label']!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: stardustWhite),
                                  ),
                                );
                              }).toList(),

                              onChanged: (v) => controller.selectedSign.value = v ?? '',
                            )),



                            const SizedBox(height: 20),

                            /// 📅 DATE
                            Obx(() => Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              crossAxisAlignment:
                              WrapCrossAlignment.center,
                              children: [
                                const Icon(Icons.calendar_today,
                                    color: celestialGold),
                                Text(
                                  DateFormat('yyyy-MM-dd').format(
                                      controller.selectedDate.value),
                                  style: const TextStyle(
                                      color: stardustWhite),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    final picked =
                                    await showDatePicker(
                                      context: context,
                                      initialDate:
                                      controller.selectedDate.value,
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime.now(),
                                    );
                                    if (picked != null) {
                                      controller.selectedDate.value =
                                          picked;
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                      celestialGold),
                                  child: const Text('Pick Date'),
                                )
                              ],
                            )),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    Obx(() => ElevatedButton.icon(
                      onPressed: controller.isLoading.value
                          ? null
                          : _handlePrediction,
                      icon: controller.isLoading.value
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2),
                      )
                          : const Icon(Icons.stars),
                      label: Text(
                        'Get ${widget.serviceName} • ₹${widget.servicePrice.toStringAsFixed(0)}',
                        style:
                        const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: celestialGold,
                        foregroundColor: cosmicBlue,
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
