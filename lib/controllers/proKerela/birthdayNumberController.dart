import 'package:get/get.dart';
import '../../apiManager/apiServices.dart';
import '../../model/proKerla/birthdayNumberModel.dart';

class BirthdayNumberController extends GetxController {
  final ApiService apiService;

  BirthdayNumberController({required this.apiService});

  /// Indicates whether a request is in progress
  final isLoading = false.obs;

  /// Holds any error message
  final errorMessage = ''.obs;

  /// Holds the fetched BirthdayNumberModel (nullable)
  final birthdayNumber = Rxn<BirthdayNumberModel>();

  /// Fetches the Birthday Number for the given date
  Future<BirthdayNumberModel?> fetchBirthdayNumber({
    required DateTime dateTime,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await apiService.getBirthdayNumber(dateTime: dateTime);
      if (result != null) {
        birthdayNumber.value = result;
        return result;
      } else {
        errorMessage.value = 'No data received';
        birthdayNumber.value = null;
        return null;
      }
    } catch (e) {
      errorMessage.value = 'Error fetching data: $e';
      birthdayNumber.value = null;
      return null;
    } finally {
      isLoading.value = false;
    }
  }
}
