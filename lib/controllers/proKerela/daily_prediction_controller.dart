import 'package:get/get.dart';
import '../../apiManager/apiServices.dart' show ApiService;
import '../../model/proKerla/dailyPredictionModel.dart';
import '../../views/proKerela/dailyPredictionResult.dart' show DailyPredictionResultScreen;

class DailyPredictionController extends GetxController {
  final ApiService _apiService = ApiService();

  // ✅ Add this line to fix the error
  var selectedSign = ''.obs;

  // Optional: Also include a date picker
  var selectedDate = DateTime.now().obs;

  var isLoading = false.obs;
  var prediction = Rxn<DailyPredictionModel>();
  var error = ''.obs;

  void fetchPrediction() async {
    try {
      isLoading.value = true;
      error.value = '';

      final response = await _apiService.fetchDailyPrediction(
        sign: selectedSign.value,
        datetime: selectedDate.value,
      );

      prediction.value = response;

      // ✅ Navigate here using class, not name
      Get.to(() => DailyPredictionResultScreen());
    } catch (e) {
      error.value = 'Failed to load prediction: $e';
    } finally {
      isLoading.value = false;
    }
  }

}
