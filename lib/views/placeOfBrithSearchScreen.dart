// import 'dart:convert';

// import 'package:AstrowayCustomer/controllers/IntakeController.dart';
// import 'package:AstrowayCustomer/controllers/callController.dart';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;

// import 'package:AstrowayCustomer/controllers/kundliController.dart';
// import 'package:AstrowayCustomer/controllers/kundliMatchingController.dart';
// import 'package:AstrowayCustomer/controllers/reportController.dart';
// import 'package:AstrowayCustomer/controllers/search_controller.dart';
// import 'package:AstrowayCustomer/controllers/search_place_controller.dart';
// import 'package:AstrowayCustomer/controllers/userProfileController.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:get/get.dart';

// import '../widget/commonAppbar.dart';
// import 'package:AstrowayCustomer/utils/global.dart' as global;

// // ignore: must_be_immutable
// class PlaceOfBirthSearchScreen extends StatelessWidget {
//   final int? flagId;
//   PlaceOfBirthSearchScreen({Key? key, this.flagId}) : super(key: key);
//   UserProfileController userProfileController =
//       Get.find<UserProfileController>();
//   KundliController kundliController = Get.find<KundliController>();
//   IntakeController callIntakeController = Get.find<IntakeController>();
//   ReportController reportController = Get.find<ReportController>();
//   KundliMatchingController kundliMatchingController =
//       Get.find<KundliMatchingController>();
//   CallController callController = Get.find<CallController>();
//   SearchControllerCustom searchController = Get.find<SearchControllerCustom>();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: PreferredSize(
//         preferredSize: Size.fromHeight(56),
//         child: CommonAppBar(
//           title: tr('Place of Birth'),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child:
//             GetBuilder<SearchPlaceController>(builder: (searchPlaceController) {
//           return Column(
//             children: [
//               SizedBox(
//                 height: 40,
//                 child: TextField(
//                   onChanged: (value) async {
//                     await searchPlaceController.autoCompleteSearch(value);
//                   },
//                   controller: searchPlaceController.searchController,
//                   decoration: InputDecoration(
//                       isDense: true,
//                       prefixIcon: Icon(
//                         Icons.search,
//                         color: Get.theme.iconTheme.color,
//                       ),
//                       border: OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.grey),
//                         borderRadius: BorderRadius.all(Radius.circular(25.0)),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.grey),
//                         borderRadius: BorderRadius.all(Radius.circular(25.0)),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.grey),
//                         borderRadius: BorderRadius.all(Radius.circular(25.0)),
//                       ),
//                       hintText: 'Search City',
//                       hintStyle: TextStyle(
//                           color: Colors.black,
//                           fontSize: 12,
//                           fontWeight: FontWeight.w500)),
//                 ),
//               ),
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: searchPlaceController.predictions!.length,
//                   itemBuilder: (context, index) {
//                     return ListTile(
//                       leading: CircleAvatar(
//                         child: Icon(
//                           Icons.location_on,
//                           color: Colors.white,
//                         ),
//                       ),
//                       title: Text(searchPlaceController
//                           .predictions![index].primaryText),
//                       onTap: () async {
//                         List<Location> location;
//                         if (kIsWeb) {
//                           List<Map<String, double>> hardcodedData = [
//                             {'latitude': 40.7128, 'longitude': -74.0060},
//                             {'latitude': 40.7128, 'longitude': -74.0060},
//                           ];
//                           location = hardcodedData.map((data) {
//                             return Location(
//                                 latitude: data['latitude']!,
//                                 longitude: data['longitude']!,
//                                 timestamp: DateTime.now());
//                           }).toList();
//                         } else {
//                           print("timezone");
//                           print(
//                               "${searchPlaceController.predictions![index].primaryText.toString()}");
//                           location = await locationFromAddress(
//                             searchPlaceController
//                                 .predictions![index].primaryText
//                                 .toString(),
//                           );
//                         }
//                         debugPrint('loc lat is ${location[0].latitude}');
//                         kundliController.lat = location[0].latitude;
//                         kundliController.long = location[0].longitude;

//                         kundliMatchingController.lat = location[0].latitude;
//                         kundliMatchingController.long = location[0].longitude;
//                         print('${location[0].latitude} :- location');
//                         print('${location[0].longitude} :- location');
//                         await kundliController.getGeoCodingLatLong(
//                             latitude: location[0].latitude,
//                             longitude: location[0].longitude,
//                             flagId: flagId,
//                             kundliMatchingController: kundliMatchingController);
//                         searchPlaceController.searchController.text =
//                             searchPlaceController
//                                 .predictions![index].primaryText;
//                         searchPlaceController.update();
//                         kundliController.birthKundliPlaceController.text =
//                             searchPlaceController
//                                 .predictions![index].primaryText;
//                         kundliController.update();

//                         kundliController.editBirthPlaceController.text =
//                             searchPlaceController
//                                 .predictions![index].primaryText;
//                         kundliController.update();
//                         if (flagId == 1) {
//                           kundliMatchingController.cBoysBirthPlace.text =
//                               searchPlaceController
//                                   .predictions![index].primaryText;
//                           kundliMatchingController.boyLat =
//                               location[0].latitude;
//                           kundliMatchingController.boyLong =
//                               location[0].longitude;
//                           kundliMatchingController.update();
//                         }
//                         if (flagId == 2) {
//                           kundliMatchingController.cGirlBirthPlace.text =
//                               searchPlaceController
//                                   .predictions![index].primaryText;
//                           kundliMatchingController.girlLat =
//                               location[0].latitude;
//                           kundliMatchingController.girlLong =
//                               location[0].longitude;
//                           kundliMatchingController.update();
//                         }
//                         if (flagId == 4) {
//                           userProfileController.addressController.text =
//                               searchPlaceController
//                                   .predictions![index].primaryText;
//                         }
//                         if (flagId == 3) {
//                           userProfileController.placeBirthController.text =
//                               searchPlaceController
//                                   .predictions![index].primaryText;
//                         }
//                         if (flagId == 5) {
//                           callIntakeController.lat = location[0].latitude;
//                           callIntakeController.long = location[0].longitude;
//                           callIntakeController.getGeoCodingLatLong(
//                               latitude: callIntakeController.lat,
//                               longitude: callIntakeController.long);
//                           callIntakeController.placeController.text =
//                               searchPlaceController
//                                   .predictions![index].primaryText;
//                         }
//                         if (flagId == 6) {
//                           callIntakeController.partnerPlaceController.text =
//                               searchPlaceController
//                                   .predictions![index].primaryText;
//                         }
//                         if (flagId == 7) {
//                           reportController.placeController.text =
//                               searchPlaceController
//                                   .predictions![index].primaryText;
//                           reportController.update();
//                         }
//                         if (flagId == 8) {
//                           reportController.partnerPlaceController.text =
//                               searchPlaceController
//                                   .predictions![index].primaryText;
//                           reportController.update();
//                         }
//                         callIntakeController.update();
//                         Get.back();
//                       },
//                     );
//                   },
//                 ),
//               ),
//             ],
//           );
//         }),
//       ),
//     );
//   }

//   Future<List<Location>> getLocationFromAddress(String address) async {
//     final url = Uri.parse(
//         'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=${global.getSystemFlagValue(global.systemFlagNameList.googleMapApiKey)}');

//     debugPrint('location url: ${url}');

//     final response = await http.get(url);

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       if (data['status'] == 'OK') {
//         final location = data['results'][0]['geometry']['location'];
//         debugPrint('location lat : ${location['lat']}');
//         debugPrint('location long : ${location['long']}');
//         debugPrint('location : ${location}');

//         return [
//           // Location(latitude: location['lat'], longitude: location['lng'])
//         ]; // Assuming Location class has lat and lng properties
//       } else {
//         print('Geocoding error: ${data['status']}');
//         return [];
//       }
//     } else {
//       print('Error fetching location data: ${response.statusCode}');
//       return [];
//     }
//   }
// }

import 'dart:async'; // Add for Timer
import 'package:AstrowayCustomer/controllers/search_place_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:AstrowayCustomer/utils/services/location_service.dart'; // YOUR NOMINATIM SERVICE
import 'package:AstrowayCustomer/controllers/IntakeController.dart';
import 'package:AstrowayCustomer/controllers/callController.dart';
import 'package:AstrowayCustomer/controllers/kundliController.dart';
import 'package:AstrowayCustomer/controllers/kundliMatchingController.dart';
import 'package:AstrowayCustomer/controllers/reportController.dart';
import 'package:AstrowayCustomer/controllers/search_controller.dart'; // Assuming this is general search
import 'package:AstrowayCustomer/controllers/userProfileController.dart';
import 'package:AstrowayCustomer/widget/commonAppbar.dart';

// Your existing SearchPlaceController remains largely the same.
// The debug prints were added in the previous response, keeping them for clarity.
// class SearchPlaceController extends GetxController {
//   TextEditingController searchController = TextEditingController();
//   List<LocationSuggestion> predictions = [];
//   Timer? _debounce;

//   @override
//   void onInit() {
//     super.onInit();
//     searchController.addListener(() {
//       print(
//           'SearchPlaceController: Listener triggered. Current text: ${searchController.text}'); // DEBUG
//       if (_debounce?.isActive ?? false) _debounce!.cancel();
//       _debounce = Timer(const Duration(milliseconds: 500), () {
//         print(
//             'SearchPlaceController: Debounce finished. Querying: ${searchController.text}'); // DEBUG
//         if (searchController.text.isNotEmpty &&
//             searchController.text.length >= 3) {
//           fetchNominatimSuggestions(searchController.text);
//         } else {
//           predictions = [];
//           print(
//               'SearchPlaceController: Query too short or empty, predictions cleared.'); // DEBUG
//           update(); // Update UI to clear suggestions
//         }
//       });
//     });
//   }

//   @override
//   void onClose() {
//     _debounce?.cancel();
//     searchController.dispose();
//     super.onClose();
//   }

//   Future<void> fetchNominatimSuggestions(String query) async {
//     try {
//       predictions = await LocationService.fetchCitySuggestions(query);
//       print(
//           'SearchPlaceController: Fetched ${predictions.length} predictions.'); // DEBUG
//       update(); // Trigger UI rebuild with new predictions
//     } catch (e) {
//       print(
//           'SearchPlaceController: Error fetching Nominatim suggestions: $e'); // DEBUG
//       predictions = [];
//       update();
//     }
//   }
// }

// ignore: must_be_immutable
class PlaceOfBirthSearchScreen extends StatelessWidget {
  final int? flagId;
  PlaceOfBirthSearchScreen({Key? key, this.flagId}) : super(key: key);

  // Initialize controllers - ensure they are already registered with Get.put()
  // Using `late final` to ensure they are looked up when first accessed,
  // assuming they are indeed registered globally via Get.put() elsewhere
  late final UserProfileController userProfileController =
      Get.find<UserProfileController>();
  late final KundliController kundliController = Get.find<KundliController>();
  late final IntakeController callIntakeController =
      Get.find<IntakeController>();
  late final ReportController reportController = Get.find<ReportController>();
  late final KundliMatchingController kundliMatchingController =
      Get.find<KundliMatchingController>();
  late final CallController callController = Get.find<CallController>();
  late final SearchControllerCustom searchControllerCustom =
      Get.find<SearchControllerCustom>();

  @override
  Widget build(BuildContext context) {
    // Explicitly put the SearchPlaceController here if it's not put globally
    // This ensures an instance is available for this screen.
    if (!Get.isRegistered<SearchPlaceController>()) {
      Get.put(SearchPlaceController());
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56), // Use const for PreferredSize
        child: CommonAppBar(
          title: tr('Place of Birth'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child:
            GetBuilder<SearchPlaceController>(builder: (searchPlaceController) {
          return Column(
            children: [
              SizedBox(
                height: 40,
                child: TextField(
                  onChanged: (value) {
                    // Removed: searchPlaceController.searchController.text = value;
                    // The TextField's controller already updates its text.
                    // The addListener in SearchPlaceController's onInit will react to this change naturally.
                    // No explicit action needed here for text updating.
                  },
                  controller: searchPlaceController.searchController,
                  decoration: InputDecoration(
                      isDense: true,
                      prefixIcon: Icon(
                        Icons.search,
                        color: Get.theme.iconTheme.color,
                      ),
                      border: const OutlineInputBorder(
                        // Added const
                        borderSide: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        // Added const
                        borderSide: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        // Added const
                        borderSide: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      ),
                      hintText: 'Search City',
                      hintStyle: const TextStyle(
                          // Added const
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ),
              ),
              // Expanded(
              //   child: ListView.builder(
              //     itemCount: searchPlaceController.predictions.length,
              //     itemBuilder: (context, index) {
              //       final suggestion = searchPlaceController.predictions[index];
              //       return ListTile(
              //         leading: const CircleAvatar(
              //           // Added const
              //           child: Icon(
              //             Icons.location_on,
              //             color: Colors.white,
              //           ),
              //         ),
              //         title: Text(suggestion.displayName),
              //         onTap: () async {
              //           final double? lat = double.tryParse(suggestion.lat);
              //           final double? long = double.tryParse(suggestion.lon);

              //           if (lat == null || long == null) {
              //             print(
              //                 'Error: Could not parse latitude or longitude from suggestion. Lat: ${suggestion.lat}, Lon: ${suggestion.lon}');
              //             // Optionally show a snackbar or alert to the user
              //             Get.snackbar(
              //               'Error',
              //               'Could not get coordinates for this place. Please try another.',
              //               snackPosition: SnackPosition.BOTTOM,
              //               backgroundColor: Colors.red,
              //               colorText: Colors.white,
              //             );
              //             return;
              //           }

              //           debugPrint('Selected location lat: $lat, long: $long');

              //           _updateControllerWithLocation(
              //               placeName: suggestion.displayName,
              //               lat: lat,
              //               long: long,
              //               flagId: flagId,
              //               kundliController: kundliController,
              //               kundliMatchingController: kundliMatchingController,
              //               userProfileController: userProfileController,
              //               callIntakeController: callIntakeController,
              //               reportController: reportController);

              //           Get.back(); // Go back after selecting a place
              //         },
              //       );
              //     },
              //   ),
              // ),
            ],
          );
        }),
      ),
    );
  }

  // This method centralizes the logic for updating various controllers
  void _updateControllerWithLocation({
    required String placeName,
    required double lat,
    required double long,
    int? flagId,
    required KundliController kundliController,
    required KundliMatchingController kundliMatchingController,
    required UserProfileController userProfileController,
    required IntakeController callIntakeController,
    required ReportController reportController,
  }) {
    switch (flagId) {
      case 1: // KundliMatchingController (Boy)
        kundliMatchingController.cBoysBirthPlace.text = placeName;
        kundliMatchingController.boyLat = lat;
        kundliMatchingController.boyLong = long;
        kundliMatchingController.update();
        break;
      case 2: // KundliMatchingController (Girl)
        kundliMatchingController.cGirlBirthPlace.text = placeName;
        kundliMatchingController.girlLat = lat;
        kundliMatchingController.girlLong = long;
        kundliMatchingController.update();
        break;
      case 3: // UserProfileController (Birth Place)
        userProfileController.placeBirthController.text = placeName;
        // Ensure you add these properties to UserProfileController if you intend to store them
        // userProfileController.birthLat = lat;
        // userProfileController.birthLong = long;
        userProfileController.update();
        break;
      case 4: // UserProfileController (Address)
        userProfileController.addressController.text = placeName;
        // Ensure you add these properties to UserProfileController if you intend to store them
        // userProfileController.addressLat = lat;
        // userProfileController.addressLong = long;
        userProfileController.update();
        break;
      case 5: // IntakeController (Caller's Place)
        callIntakeController.placeController.text = placeName;
        callIntakeController.lat = lat;
        callIntakeController.long = long;
        // Call getGeoCodingLatLong if it performs additional logic like timezone
        callIntakeController.getGeoCodingLatLong(
            latitude: lat, longitude: long);
        callIntakeController.update();
        break;
      case 6: // IntakeController (Partner's Place)
        callIntakeController.partnerPlaceController.text = placeName;
        // Ensure you add these properties to IntakeController if you intend to store them
        // callIntakeController.partnerLat = lat;
        // callIntakeController.partnerLong = long;
        callIntakeController.update();
        break;
      case 7: // ReportController (Place of Birth)
        reportController.placeController.text = placeName;
        reportController.latitude = lat;
        reportController.longitude = long;
        reportController.update();
        break;
      case 8: // ReportController (Partner's Place)
        reportController.partnerPlaceController.text = placeName;
        // Ensure you add these properties to ReportController if you intend to store them
        // reportController.partnerLatitude = lat;
        // reportController.partnerLongitude = long;
        reportController.update();
        break;
      default: // KundliController (General Birth Place)
        kundliController.birthKundliPlaceController.text = placeName;
        kundliController.editBirthPlaceController.text = placeName;
        kundliController.lat = lat;
        kundliController.long = long;
        // Call getGeoCodingLatLong if it performs additional logic like timezone
        kundliController.getGeoCodingLatLong(
            latitude: lat,
            longitude: long,
            flagId: flagId,
            kundliMatchingController: kundliMatchingController);
        kundliController.update();
        break;
    }
  }

  // Remove the old getLocationFromAddress method as it's Google-specific
  // Future<List<Location>> getLocationFromAddress(String address) async { /* ... */ }
}
