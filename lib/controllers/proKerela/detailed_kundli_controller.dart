import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';

import '../../apiManager/apiServices.dart';
import '../../model/proKerla/detailedKundliModel.dart'; // Ensure this path is correct

class DetailedKundliController extends GetxController {
  var isLoading = false.obs;
  // Rxn<DetailedKundliModel> is correct for nullable Rx
  var kundliData = Rxn<KundliModel>();
  var errorMessage = ''.obs;

  Future<void> fetchFromInputFields({
    required String cityName,
    required String date,
    required String time,
    required int ayanamsa,
    required String language,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = ''; // Clear previous error

      // Parse date and time string to DateTime
      final DateTime dateTime = DateFormat("yyyy-MM-dd HH:mm").parse('$date $time');

      // Convert cityName to coordinates using geocoding package
      List<Location> locations = await locationFromAddress(cityName);
      if (locations.isEmpty) {
        errorMessage.value = 'City not found. Please check the spelling or try another city.';
        kundliData.value = null; // Ensure kundliData is cleared on error
        return;
      }
      final latitude = locations.first.latitude;
      final longitude = locations.first.longitude;

      // Fetch detailed kundli data
      final KundliModel? apiResponse = await ApiService().fetchDetailedKundli(
        ayanamsa: ayanamsa,
        latitude: latitude,
        longitude: longitude,
        datetime: dateTime,
        language: language,
      );

      // Check if API response itself is null or status is not 'ok'
      if (apiResponse == null || apiResponse.status != 'ok') {
        errorMessage.value = apiResponse?.status == 'ok' ? 'Failed to fetch Kundli data. Status: ${apiResponse?.status}' : 'An unexpected error occurred with the API response.';
        kundliData.value = null; // Clear data if not successful
        return;
      }

      // If status is 'ok', assign the entire response model to kundliData.value
      // Your UI then accesses kundliData.value!.data!
      kundliData.value = apiResponse;
      print('Controller: Kundli data assigned. Nakshatra: ${kundliData.value?.data?.nakshatraDetails?.nakshatra?.name}');


    } catch (e) {
      errorMessage.value = 'An error occurred: ${e.toString()}. Please try again.';
      kundliData.value = null; // Clear data on any exception
      print('Error in DetailedKundliController: $e'); // For debugging
    } finally {
      isLoading.value = false; // Always set loading to false
    }
  }
}