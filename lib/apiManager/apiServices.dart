import 'dart:convert';
import 'package:AstrowayCustomer/apiManager/endpoints.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/proKerla/InauspiciousModel.dart';
import '../model/proKerla/LoveCompatibilityModel.dart';
import '../model/proKerla/auspicious_period_model.dart';
import '../model/proKerla/birthdayNumberModel.dart';
import '../model/proKerla/dailyPredictionModel.dart';
import '../model/proKerla/detailedKundliModel.dart';
import '../model/proKerla/muhuratModel.dart';
import '../model/proKerla/panchangModel.dart';
import '../model/proKerla/planetPositionModel.dart';

// Assuming this is defined somewhere, e.g., in endpoints.dart
// static const String baseAstrologyUrl = 'https://api.prokerala.com/v2/astrology';

class ApiService {
  final String clientId = '0eb707a4-c19e-4cd3-ab59-c45a022eeceb';
  final String clientSecret = 'orckG5duJhLrrxZEGsXKcFnJiK07JXRm8cTBVZXT';

  String? _accessToken;
  DateTime? _tokenExpiry;

  ApiService() {
    _loadTokenFromPrefs();
  }

  Future<void> _loadTokenFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    final expiryMillis = prefs.getInt('token_expiry');
    if (expiryMillis != null) {
      _tokenExpiry = DateTime.fromMillisecondsSinceEpoch(expiryMillis);
    }
  }

  Future<void> _saveTokenToPrefs(String token, int expiresInSeconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
    final expiry = DateTime.now().add(Duration(seconds: expiresInSeconds));
    await prefs.setInt('token_expiry', expiry.millisecondsSinceEpoch);
    _accessToken = token;
    _tokenExpiry = expiry;
  }

  Future<String> fetchAccessToken() async {
    final url = Uri.parse('https://api.prokerala.com/token');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'grant_type': 'client_credentials',
        'client_id': clientId,
        'client_secret': clientSecret,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['access_token'] as String?;
      final expiresIn = data['expires_in'] as int? ?? 3600;
      if (token != null) {
        await _saveTokenToPrefs(token, expiresIn);
        return token;
      } else {
        throw Exception('Access token missing in response');
      }
    } else {
      throw Exception('Failed to fetch access token: ${response.statusCode}');
    }
  }

  Future<String> _getValidAccessToken() async {
    if (_accessToken != null && _tokenExpiry != null) {
      if (DateTime.now().isBefore(_tokenExpiry!)) {
        // Token still valid
        return _accessToken!;
      }
    }
    // Token missing or expired, fetch new one
    return await fetchAccessToken();
  }

  Future<T> _getWithAuthRetry<T>(
    Uri uri,
    T Function(Map<String, dynamic> json) fromJson, {
    bool expectDataKey = true,
  }) async {
    String token = await _getValidAccessToken();

    // First attempt
    http.Response response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json', // Good practice
        'Authorization': 'Bearer $token',
      },
    );

    // Retry on 401/403
    if (response.statusCode == 401 || response.statusCode == 403) {
      token = await fetchAccessToken(); // Fetch new token
      response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json', // Good practice
          'Authorization': 'Bearer $token',
        },
      );
    }

    // --- CRITICAL CHANGE HERE: UTF-8 DECODING ---
    final String decodedBody = utf8.decode(response.bodyBytes);
    // FOR DEBUGGING: Print the raw bytes and the decoded string
    print("--- Raw Response Bytes from API ---");
    print(response.bodyBytes);
    print("--- Decoded Response Body (UTF-8) ---");
    print(decodedBody);
    // --- END CRITICAL CHANGE ---

    final decodedJson = jsonDecode(decodedBody) as Map<String, dynamic>;
    print(
        '${uri.path} Response (${response.statusCode}): $decodedJson'); // This will now show Hindi

    if (response.statusCode == 200) {
      if (expectDataKey) {
        final data = decodedJson['data'];
        if (data != null && data is Map<String, dynamic>) {
          return fromJson(data);
        } else {
          // Fallback: pass entire decoded if 'data' key missing or not a Map
          // This ensures fromJson still gets a Map<String, dynamic>
          return fromJson(decodedJson);
        }
      } else {
        // No 'data' key expected, pass the whole decoded JSON map
        return fromJson(decodedJson);
      }
    } else {
      throw Exception(
        'Failed to load data from ${uri.path}: ${response.statusCode} - ${decodedJson['message'] ?? ''}',
      );
    }
  }

  Future<AuspiciousPeriodModel> fetchAuspiciousPeriods({
    required int ayanamsa,
    required double latitude,
    required double longitude,
    required DateTime datetime,
    required String language,
  }) async {
    final queryParameters = {
      'ayanamsa': ayanamsa.toString(),
      'coordinates':
          '${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}',
      'datetime': toIso8601WithTimezone(datetime),
      'la': language, // Note: using 'la' for language here
    };

    final uri = Uri.parse(ApiEndpoints.auspiciousPeriods).replace(
      queryParameters: queryParameters,
    );

    return _getWithAuthRetry<AuspiciousPeriodModel>(
      uri,
      (json) => AuspiciousPeriodModel.fromJson(json),
    );
  }

  Future<InauspiciousPeriodModel> fetchInauspiciousPeriods({
    required int ayanamsa,
    required double latitude,
    required double longitude,
    required DateTime datetime,
    required String language,
  }) async {
    final queryParameters = {
      'ayanamsa': ayanamsa.toString(),
      'coordinates':
          '${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}',
      'datetime': toIso8601WithTimezone(datetime),
      'la': language, // Note: using 'la' for language here
    };

    final uri = Uri.parse(ApiEndpoints.auspiciousPeriods).replace(
      // Should this be inauspiciousPeriods?
      queryParameters: queryParameters,
    );

    return _getWithAuthRetry<InauspiciousPeriodModel>(
      uri,
      (json) => InauspiciousPeriodModel.fromJson(json),
    );
  }

  Future<DetailedPanchangModel> fetchDailyPanchang({
    required int ayanamsa,
    required double latitude,
    required double longitude,
    required DateTime datetime,
    required String language,
  }) async {
    final queryParameters = {
      'ayanamsa': ayanamsa.toString(),
      'coordinates':
          '${latitude.toStringAsFixed(2)},${longitude.toStringAsFixed(2)}',
      'datetime': toIso8601WithTimezone(datetime),
      'la': language, // Using 'language' here
    };

    final uri = Uri.parse(ApiEndpoints.panchang)
        .replace(queryParameters: queryParameters);

    return _getWithAuthRetry<DetailedPanchangModel>(
        uri, (json) => DetailedPanchangModel.fromJson(json));
  }

  Future<InauspiciousModel> fetchInauspiciousPeriod({
    required int ayanamsa,
    required double latitude,
    required double longitude,
    required DateTime datetime,
    required String language,
  }) async {
    final queryParameters = {
      'ayanamsa': ayanamsa.toString(),
      'coordinates':
          '${latitude.toStringAsFixed(2)},${longitude.toStringAsFixed(2)}',
      'datetime': toIso8601WithTimezone(datetime),
      'la': language, // Using 'language' here
    };

    final uri = Uri.parse(ApiEndpoints.inauspiciousPeriods)
        .replace(queryParameters: queryParameters);

    return _getWithAuthRetry<InauspiciousModel>(
        uri, (json) => InauspiciousModel.fromJson(json));
  }

  Future<PlanetPositionModel> fetchPlanetPosition({
    required int ayanamsa,
    required double latitude,
    required double longitude,
    required DateTime datetime,
    required String language,
    String? planets,
  }) async {
    final queryParameters = {
      'ayanamsa': ayanamsa.toString(),
      'coordinates':
          '${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}',
      'datetime': toIso8601WithTimezone(datetime),
      'la': language, // Note: using 'la' for language here
    };

    if (planets != null && planets.isNotEmpty) {
      queryParameters['planets'] = planets;
    }

    final uri = Uri.parse(ApiEndpoints.planetPosition)
        .replace(queryParameters: queryParameters);

    print("🌍 Full URI: $uri");

    return _getWithAuthRetry<PlanetPositionModel>(
      uri,
      (json) {
        print("✅ Raw JSON: $json");

        // If json is a List, wrap it in a Map
        // This logic should ideally be handled in PlanetPositionModel.fromJson itself,
        // but keeping it here as per your original code.
        if (json is List) {
          json = {'planet_position': json};
        }

        return PlanetPositionModel.fromJson(json);
      },
    );
  }

  // adjust path if different

  Future<DailyPredictionModel> fetchDailyPrediction({
    required DateTime datetime,
    required String sign,
  }) async {
    final queryParameters = {
      'datetime': toIso8601WithTimezone(datetime),
      'sign': sign.toLowerCase(),
    };

    final uri = Uri.parse(ApiEndpoints.dailyHoroscope)
        .replace(queryParameters: queryParameters);

    return _getWithAuthRetry<DailyPredictionModel>(
      uri,
      (json) => DailyPredictionModel.fromJson(json),
    );
  }

  Future<KundliModel?> fetchDetailedKundli({
    required int ayanamsa,
    required double latitude,
    required double longitude,
    required DateTime datetime,
    required String language,
  }) async {
    final queryParameters = {
      'ayanamsa': ayanamsa.toString(),
      'coordinates':
          '${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}',
      'datetime': toIso8601WithTimezone(datetime),
      'la': language, // Using 'language' here
    };

    final uri = Uri.parse(ApiEndpoints.detailedKundli)
        .replace(queryParameters: queryParameters);

    try {
      print("📡 Requesting Kundli from: $uri");

      return await _getWithAuthRetry<KundliModel>(
        uri,
        (json) {
          try {
            // Note: The `json` here will already be the correctly decoded Map
            // from _getWithAuthRetry. So, "Raw JSON Response" will show Hindi.
            print("📥 Raw JSON Response: $json");
            final parsed = KundliModel.fromJson(json);
            print("✅ Parsed KundliModel: ${parsed.toJson()}");
            return parsed;
          } catch (e, st) {
            print("❌ Error while parsing KundliModel: $e");
            print("🪵 Stacktrace: $st");
            throw Exception("Failed to parse KundliModel: $e");
          }
        },
        expectDataKey: false, // Important: disable 'data' key extraction here
      );
    } catch (e, st) {
      print("❌ API request failed: $e");
      print("🪵 Stacktrace: $st");
      return null;
    }
  }

  Future<LoveCompatibilityModel?> getLoveCompatibility({
    required String signOne,
    required String signTwo,
    required DateTime dateTime,
  }) async {
    final queryParameters = {
      'datetime': toIso8601WithTimezone(dateTime),
      'sign_one': signOne.toLowerCase(),
      'sign_two': signTwo.toLowerCase(),
    };

    final uri = Uri.parse(ApiEndpoints.loveCompatibility)
        .replace(queryParameters: queryParameters);

    try {
      return await _getWithAuthRetry<LoveCompatibilityModel>(
        uri,
        (json) => LoveCompatibilityModel.fromJson(json),
        expectDataKey:
            false, // Use false if the API returns data at root, adjust if needed
      );
    } catch (e) {
      print('❌ Error fetching love compatibility: $e');
      return null;
    }
  }

  /// Fetches the “Birthday Number” for a given date.
  Future<BirthdayNumberModel?> getBirthdayNumber({
    required DateTime dateTime,
  }) async {
    // 1. Build query parameters, encoding the ISO8601 datetime so "+" becomes "%2B"
    final queryParameters = {
      'datetime': toIso8601WithTimezone(dateTime),
    };

    // 2. Construct the full URI
    //    (Make sure ApiEndpoints.birthdayNumber is defined, see note below.)
    final uri = Uri.parse(ApiEndpoints.birthdayNumber)
        .replace(queryParameters: queryParameters);

    try {
      // 3. Use _getWithAuthRetry<T> to handle token + 401/403 retry logic.
      //    We rely on the default expectDataKey: true, so `fromJson` receives
      //    the contents of `"data"`, i.e. { "birthday_number": { … } }.
      return await _getWithAuthRetry<BirthdayNumberModel>(
        uri,
        (json) => BirthdayNumberModel.fromJson(json),
        // expectDataKey is true by default, so no need to explicitly add it here.
      );
    } catch (e) {
      print('❌ Error fetching birthday number: $e');
      return null;
    }
  }
}

String toIso8601WithTimezone(DateTime dateTime) {
  final tzOffset = dateTime.timeZoneOffset;
  final sign = tzOffset.isNegative ? '-' : '+';

  String twoDigits(int n) => n.abs().toString().padLeft(2, '0');

  final hours = twoDigits(tzOffset.inHours);
  final minutes = twoDigits(tzOffset.inMinutes.remainder(60));

  final basicIso = dateTime.toIso8601String().split('.').first;

  return '$basicIso$sign$hours:$minutes';
}
