import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';

import '../../apiManager/apiServices.dart';
import '../../model/proKerla/detailedKundliModel.dart';

class DetailedKundliController extends GetxController {
  var isLoading = false.obs;
  var kundliData = Rxn<KundliModel>();
  var errorMessage = ''.obs;

  Future<void> fetchFromInputFields({
    required String cityName,
    required String date,
    required String time,
    required int ayanamsa,
    required String language,
  }) async {
    print('========== KUNDLI CONTROLLER START ==========');

    try {
      isLoading.value = true;
      errorMessage.value = '';
      kundliData.value = null;

      print('INPUT RECEIVED');
      print('City     : $cityName');
      print('Date     : $date');
      print('Time     : $time');
      print('Ayanamsa : $ayanamsa');
      print('Language : $language');

      // ---------- DATE TIME ----------
      print('Parsing DateTime...');
      final DateTime dateTime =
      DateFormat("yyyy-MM-dd HH:mm").parse('$date $time');
      print('Parsed DateTime: $dateTime');

      // ---------- GEOCODING ----------
      print('Calling locationFromAddress...');
      List<Location> locations = await locationFromAddress(cityName);

      print('Geocoding result length: ${locations.length}');

      if (locations.isEmpty) {
        errorMessage.value =
        'City not found. Please check the spelling or try another city.';
        kundliData.value = null;
        print('ERROR: No locations found for city');
        return;
      }

      final latitude = locations.first.latitude;
      final longitude = locations.first.longitude;

      print('Latitude  : $latitude');
      print('Longitude : $longitude');

      // ---------- API CALL ----------
      print('Calling fetchDetailedKundli API...');
      final KundliModel? apiResponse =
      await ApiService().fetchDetailedKundli(
        ayanamsa: ayanamsa,
        latitude: latitude,
        longitude: longitude,
        datetime: dateTime,
        language: language,
      );

      print('API call completed');

      if (apiResponse == null) {
        errorMessage.value = 'API returned null response';
        kundliData.value = null;
        print('ERROR: apiResponse is NULL');
        return;
      }

      print('API Status: ${apiResponse.status}');

      if (apiResponse.status != 'ok') {
        errorMessage.value =
        'API failed with status: ${apiResponse.status}';
        kundliData.value = null;
        print('ERROR: API status not ok');
        return;
      }

      // ---------- DATA ASSIGN ----------
      print('Assigning kundliData...');
      kundliData.value = apiResponse;

      print('Kundli data assigned successfully');

      print(
          'Nakshatra: ${kundliData.value?.data?.nakshatraDetails?.nakshatra?.name}');
      // print(
      //     'Rashi    : ${kundliData.value?.data?.rasiDetails?.rasi?.name}');
      // print(
      //     'Tithi    : ${kundliData.value?.data?.tithiDetails?.tithi?.name}');

      print('========== KUNDLI CONTROLLER SUCCESS ==========');

    } catch (e, stackTrace) {
      errorMessage.value =
      'An error occurred: ${e.toString()}. Please try again.';
      kundliData.value = null;

      print('========== KUNDLI CONTROLLER ERROR ==========');
      print('Exception: $e');
      print('StackTrace: $stackTrace');
    } finally {
      isLoading.value = false;
      print('Loading set to false');
      print('========== KUNDLI CONTROLLER END ==========');
    }
  }
}
