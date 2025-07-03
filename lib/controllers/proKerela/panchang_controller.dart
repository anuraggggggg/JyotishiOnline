// controllers/panchang_controller.dart

import 'package:get/get.dart';
import '../../apiManager/apiServices.dart';
import '../../model/proKerla/panchangModel.dart';  // Make sure this file contains PKPanchangModel

class PanchangFormController extends GetxController {
  final ApiService _apiService = ApiService();

  Rxn<DetailedPanchangModel> panchangData = Rxn<DetailedPanchangModel>();
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  Future<void> loadPanchang({
    required int ayanamsa,
    required double latitude,
    required double longitude,
    required DateTime datetime,
    required String language,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final  data = await _apiService.fetchDailyPanchang(
        ayanamsa: ayanamsa,
        latitude: latitude,
        longitude: longitude,
        datetime: datetime,
        language: language,
      );

      panchangData.value = data;
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
