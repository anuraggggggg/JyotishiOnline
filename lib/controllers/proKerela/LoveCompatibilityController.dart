import 'package:AstrowayCustomer/apiManager/apiServices.dart';
import 'package:get/get.dart';
import '../../model/proKerla/LoveCompatibilityModel.dart'; // Import your ApiService class here

class LoveCompatibilityController extends GetxController {
  final ApiService apiService;

  LoveCompatibilityController({required this.apiService});

  // Observable variables
  var isLoading = false.obs;
  var compatibilityResult = Rxn<LoveCompatibilityModel>();
  var errorMessage = ''.obs;

  Future<LoveCompatibilityModel?> fetchCompatibility({
    required String signOne,
    required String signTwo,
    required DateTime dateTime,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await apiService.getLoveCompatibility(
        signOne: signOne,
        signTwo: signTwo,
        dateTime: dateTime,
      );

      if (result != null) {
        compatibilityResult.value = result;
        return result; // Return the successful result
      } else {
        errorMessage.value = 'No data received';
        return null; // Return null if no data
      }
    } catch (e) {
      errorMessage.value = 'Error fetching data: $e';
      return null; // Return null on error
    } finally {
      isLoading.value = false;
    }
  }

}
