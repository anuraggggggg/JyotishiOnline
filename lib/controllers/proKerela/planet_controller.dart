import 'package:get/get.dart';

import '../../apiManager/apiServices.dart';
import '../../model/proKerla/planetPositionModel.dart';

/// GetX controller for Prokerala Planet Position feature.
/// - Holds loading/error/data state
/// - Keeps selected language observable (en/hi/ta/te/ml)
/// - Calls ApiService.fetchPlanetPosition with all required params
class PlanetController extends GetxController {
  final ApiService _api = ApiService();

  /// UI/state
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final planetResponse = Rxn<PlanetPositionModel>();

  /// Language used for `la` param. Supported: en, hi, ta, te, ml
  final selectedLanguage = 'en'.obs;

  /// Optional: set language safely (falls back to 'en' if not supported)
  void setLanguage(String lang) {
    const supported = {'en', 'hi', 'ta', 'te', 'ml'};
    selectedLanguage.value = supported.contains(lang) ? lang : 'en';
  }

  /// Clears current data & errors (useful when user edits inputs)
  void reset() {
    errorMessage.value = '';
    planetResponse.value = null;
  }

  /// Fetch planet positions from Prokerala API.
  ///
  /// ayanamsa:
  ///   1 → Lahiri, 3 → Raman, 5 → KP (per Prokerala docs)
  /// coordinates:
  ///   latitude, longitude
  /// datetime:
  ///   full DateTime; ApiService will encode as ISO8601 with zone
  /// language:
  ///   en/hi/ta/te/ml (default from [selectedLanguage])
  /// planets:
  ///   optional comma-separated planet id list, e.g. "0,1,100,102"
  Future<void> getPlanetPositions({
    required int ayanamsa,
    required double latitude,
    required double longitude,
    required DateTime datetime,
    String? language,
    String? planets,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Guard ayanamsa range (keep wide to match your UI; Prokerala commonly uses 1,3,5)
      if (ayanamsa < 1 || ayanamsa > 20) {
        throw ArgumentError('Ayanamsa must be between 1 and 20.');
      }

      final result = await _api.fetchPlanetPosition(
        ayanamsa: ayanamsa,
        latitude: latitude,
        longitude: longitude,
        datetime: datetime,
        language: (language ?? selectedLanguage.value),
        planets: planets,
      );

      if (result.planetPositions.isEmpty) {
        planetResponse.value = null;
        errorMessage.value =
        'No planet positions found for the given inputs. Please check place/date/time.';
        return;
      }

      planetResponse.value = result;
    } catch (e) {
      planetResponse.value = null;
      errorMessage.value = 'Failed to fetch planet positions: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
