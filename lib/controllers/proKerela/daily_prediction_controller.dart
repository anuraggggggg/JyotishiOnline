import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../apiManager/apiServices.dart' show ApiService;
import '../../model/proKerla/dailyPredictionModel.dart';
import '../../views/proKerela/dailyPredictionResult.dart'
    show DailyPredictionResultScreen;

class DailyPredictionController extends GetxController {
  final ApiService _apiService = ApiService();

  /// 🔹 Inputs
  final selectedSign = ''.obs;
  final selectedDate = DateTime.now().obs;

  /// 🔹 State
  final isLoading = false.obs;
  final prediction = Rxn<DailyPredictionModel>();
  final error = ''.obs;

  /// 🔹 Fetch prediction
  Future<void> fetchPrediction() async {
    debugPrint('🧭 [DailyPredictionController] fetchPrediction called');
    debugPrint('Sign: ${selectedSign.value}');
    debugPrint('Date: ${selectedDate.value.toIso8601String()}');

    if (selectedSign.value.isEmpty) {
      debugPrint('❌ Zodiac sign missing');
      error.value = 'Zodiac sign not selected';
      return;
    }

    try {
      isLoading.value = true;
      error.value = '';

      debugPrint('📡 Calling Daily Prediction API...');
      final response = await _apiService.fetchDailyPrediction(
        sign: selectedSign.value,
        datetime: selectedDate.value,
      );

      debugPrint('✅ API response received');

      if (response == null) {
        debugPrint('❌ API returned null response');
        error.value = 'No data received from server';
        return;
      }

      prediction.value = response;
      debugPrint('🧭 Prediction model set successfully');

      /// ✅ Navigation AFTER data is ready
      Get.to(() => DailyPredictionResultScreen());

      debugPrint('➡️ Navigated to DailyPredictionResultScreen');
    } catch (e, s) {
      debugPrint('🔥 Error while fetching prediction: $e');
      debugPrint('📄 StackTrace: $s');
      error.value = 'Failed to load prediction';
    } finally {
      isLoading.value = false;
      debugPrint('⏹ Loading stopped');
    }
  }
}
