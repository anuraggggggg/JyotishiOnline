import 'package:get/get.dart';

import '../../apiManager/apiServices.dart';
import '../../model/proKerla/InauspiciousModel.dart';


import 'package:get/get.dart';
import '../../model/proKerla/InauspiciousModel.dart';


class InauspiciousController extends GetxController {
  var inauspiciousData = Rxn<InauspiciousModel>();
  var isLoading = false.obs;

  Future<void> loadInauspiciousData({
    required int ayanamsa,
    required double latitude,
    required double longitude,
    required DateTime datetime,
    required String language,
  }) async {
    try {
      isLoading.value = true;

      final result = await ApiService().fetchInauspiciousPeriod(
        ayanamsa: ayanamsa,
        latitude: latitude,
        longitude: longitude,
        datetime: datetime,
        language: language,
      );

      // Wrap inside full model because fetchInauspiciousPeriod returns json['data']
      inauspiciousData.value = InauspiciousModel(muhuratList: result.muhuratList);
    } catch (e) {
      print('Error loading inauspicious data: $e');
      inauspiciousData.value = InauspiciousModel(muhuratList: []);
    } finally {
      isLoading.value = false;
    }
  }
}

