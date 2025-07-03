// planet_controller.dart
import 'package:get/get.dart';

import '../../apiManager/apiServices.dart';
import '../../model/proKerla/planetPositionModel.dart';

class PlanetController extends GetxController {
  var isLoading = false.obs;
  var planetResponse = Rxn<PlanetPositionModel>();
  var errorMessage =
      ''.obs; // <--- ADD THIS LINE: Defines the observable for error messages

  Future<void> getPlanetPositions({
    required int ayanamsa,
    required double latitude,
    required double longitude,
    required DateTime datetime,
    String language = 'en',
    String? planets,
  }) async {
    try {
      isLoading(true);
      errorMessage.value =
          ''; // <--- CLEAR previous error message at the start of a new attempt

      final response = await ApiService().fetchPlanetPosition(
        ayanamsa: ayanamsa,
        latitude: latitude,
        longitude: longitude,
        datetime: datetime,
        language: language,
        planets: planets,
      );

      // It's good practice to check if the response itself is valid/not-null,
      // and if it contains meaningful data (e.g., planetPositions is not empty).
      // Your model might have a 'status' field too, similar to DetailedKundliModel.
      // Assuming planetPositions is the primary indicator of success for this API.
      if (response != null && response.planetPositions.isNotEmpty) {
        print(
            "✅ API response parsed: ${response.planetPositions.length} planets found.");
        planetResponse.value = response;
      } else {
        // Handle cases where API call was successful but returned no data or an empty list
        errorMessage.value =
            'No planet position data received for the given inputs. Please verify the details.';
        planetResponse.value = null; // Clear any old data
        print(
            "⚠️ API response received, but no planet positions found or response was null.");
      }
    } catch (e) {
      // <--- CATCH and SET the error message here
      errorMessage.value = 'Failed to fetch planet positions: ${e.toString()}';
      planetResponse.value = null; // Ensure data is cleared on error
      print("❌ Error fetching planet positions: $e");
      // No rethrow needed if you are handling the error by setting errorMessage.
      // Rethrowing would just propagate the error up, possibly crashing the UI
      // if not caught there, and would prevent the 'finally' block from running
      // if the error is caught at a higher level without an explicit rethrow.
    } finally {
      isLoading(false); // Always stop loading
    }
  }
}
