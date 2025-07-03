// utils/services/location_service.dart
import 'dart:convert'; // For json.decode
import 'package:http/http.dart' as http; // For making HTTP requests

// This model class represents a single suggestion from Nominatim
class LocationSuggestion {
  final String displayName;
  final String lat;
  final String lon;
  final String? type; // Added type as it's often useful

  LocationSuggestion(
      {required this.displayName,
      required this.lat,
      required this.lon,
      this.type});

  // Factory constructor to create a LocationSuggestion from a JSON map
  factory LocationSuggestion.fromJson(Map<String, dynamic> json) {
    return LocationSuggestion(
      displayName: json['display_name'] ?? 'Unknown Place',
      lat: json['lat']?.toString() ??
          '0.0', // Ensure it's a string, provide default
      lon: json['lon']?.toString() ??
          '0.0', // Ensure it's a string, provide default
      type: json['type'],
    );
  }
}

class LocationService {
  static const String _nominatimBaseUrl =
      'https://nominatim.openstreetmap.org/search';

  // Important: Adhere to Nominatim's Usage Policy by providing a User-Agent.
  // Replace with your actual app name and contact info.
  static const Map<String, String> _headers = {
    'User-Agent': 'AstrowayCustomerApp/1.0 (contact@astroway.com)',
  };

  static Future<List<LocationSuggestion>> fetchCitySuggestions(
      String query) async {
    if (query.isEmpty || query.length < 3) {
      // Good practice: require a minimum input length
      return [];
    }

    try {
      final Uri uri = Uri.parse(_nominatimBaseUrl).replace(queryParameters: {
        'q': query,
        'format': 'json',
        'limit': '10', // Get up to 10 suggestions
        'addressdetails':
            '0', // Set to 1 if you need more detailed address breakdown
        // You can add more parameters like 'countrycodes' if you want to restrict searches
        // 'countrycodes': 'in', // Example: restrict to India
      });

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        // Parse the JSON response
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList
            .map((json) => LocationSuggestion.fromJson(json))
            .toList();
      } else if (response.statusCode == 403) {
        // Specific handling for 403 Forbidden - usually User-Agent or rate limit
        print(
            'Nominatim Error 403: Forbidden. Check User-Agent and rate limits.');
        print('Response Body: ${response.body}');
        // You might want to throw an exception or return an empty list based on UX
        throw Exception('Location service forbidden. Please try again later.');
      } else {
        print('Failed to load suggestions: ${response.statusCode}');
        print('Response Body: ${response.body}');
        throw Exception('Failed to load suggestions: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching suggestions: $e');
      // You can return an empty list or re-throw a more specific error
      throw Exception('Failed to fetch location suggestions: $e');
    }
  }
}
