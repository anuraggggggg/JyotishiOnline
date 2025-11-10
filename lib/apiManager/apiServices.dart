import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
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
import 'package:AstrowayCustomer/apiManager/endpoints.dart';

/// ApiService for ProKerala Astrology API with:
/// - Cached OAuth token with expiry persistence
/// - Single-flight token refresh (avoids parallel refresh storms)
/// - UTF-8 safe decoding for all responses
/// - 401/403 retry once after refresh
/// - 429 (rate limit) exponential backoff (max 3 retries)
/// - Safer helpers and endpoint fixes
class ApiService {
  ApiService() {
    _loadTokenFromPrefs();
  }

  // ⚠️ Consider moving these to secure storage/remote config.
  final String clientId = '9acbfdad-3eba-497f-b50e-e77fe0ee5dce';
  final String clientSecret = 'xs8NMZPZw2OMA1c0whXA2ceYssEvKYZJCLwD1uIQ';

  String? _accessToken;
  DateTime? _tokenExpiry;

  // Single-flight guard for token refreshes
  Future<String>? _refreshing;

  // ===== Token persistence =====
  Future<void> _loadTokenFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('pk_access_token');
    final expiryMillis = prefs.getInt('pk_token_expiry');
    if (expiryMillis != null) {
      _tokenExpiry = DateTime.fromMillisecondsSinceEpoch(expiryMillis);
    }
  }

  Future<void> _saveTokenToPrefs(String token, int expiresInSeconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pk_access_token', token);
    final expiry = DateTime.now().add(Duration(seconds: expiresInSeconds));
    await prefs.setInt('pk_token_expiry', expiry.millisecondsSinceEpoch);
    _accessToken = token;
    _tokenExpiry = expiry;
  }

  bool get _tokenIsValid =>
      _accessToken != null &&
          _tokenExpiry != null &&
          DateTime.now().isBefore(_tokenExpiry!.subtract(const Duration(seconds: 15))); // 15s skew

  Future<String> _fetchAccessToken() async {
    final url = Uri.parse('https://api.prokerala.com/token');

    final resp = await http
        .post(
      url,
      headers: const {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
      },
      body: {
        'grant_type': 'client_credentials',
        'client_id': clientId,
        'client_secret': clientSecret,
      },
    )
        .timeout(const Duration(seconds: 20));

    if (resp.statusCode == 200) {
      final data = jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
      final token = data['access_token'] as String?;
      final expiresIn = (data['expires_in'] as int?) ?? 3600;
      if (token == null) {
        throw Exception('Access token missing in response');
      }
      await _saveTokenToPrefs(token, expiresIn);
      return token;
    }

    throw Exception('Failed to fetch access token: ${resp.statusCode} ${resp.body}');
  }

  Future<String> _getValidAccessToken() async {
    if (_tokenIsValid) return _accessToken!;
    // ensure only one refresh happens
    _refreshing ??= _fetchAccessToken();
    try {
      return await _refreshing!;
    } finally {
      _refreshing = null; // clear for next time
    }
  }

  // ===== Generic GET with auth, UTF-8 decode, and retries =====
  Future<Map<String, dynamic>> _authedGetJson(
      Uri uri, {
        int retry = 0,
      }) async {
    final token = await _getValidAccessToken();

    http.Response resp;
    try {
      resp = await http
          .get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      )
          .timeout(const Duration(seconds: 25));
    } on TimeoutException {
      throw Exception('Request timeout: ${uri.path}');
    }

    // Handle common error classes
    if (resp.statusCode == 401 || resp.statusCode == 403) {
      if (retry > 0) {
        throw Exception('Unauthorized after refresh for ${uri.path}');
      }
      // force refresh and retry once
      await _fetchAccessToken();
      return _authedGetJson(uri, retry: retry + 1);
    }

    if (resp.statusCode == 429) {
      if (retry >= 3) {
        throw Exception('Rate limited (429) repeatedly for ${uri.path}');
      }
      final delayMs = 500 * (1 << retry); // 500, 1000, 2000
      await Future.delayed(Duration(milliseconds: delayMs));
      return _authedGetJson(uri, retry: retry + 1);
    }

    // Decode always with UTF-8 so Hindi etc. display correctly
    final decodedBody = utf8.decode(resp.bodyBytes);

    // Log (optional)
    // print('↪ ${uri.path} [${resp.statusCode}] => $decodedBody');

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      // Try to surface server message if any
      try {
        final err = jsonDecode(decodedBody) as Map<String, dynamic>;
        throw Exception('HTTP ${resp.statusCode} ${uri.path}: ${err['message'] ?? decodedBody}');
      } catch (_) {
        throw Exception('HTTP ${resp.statusCode} ${uri.path}: $decodedBody');
      }
    }

    final jsonMap = jsonDecode(decodedBody);
    if (jsonMap is Map<String, dynamic>) return jsonMap;
    throw Exception('Unexpected JSON type from ${uri.path}: ${jsonMap.runtimeType}');
  }

  /// Wrapper that optionally unwraps a `data` key and maps to model.
  Future<T> _getWithAuthRetry<T>(
      Uri uri,
      T Function(Map<String, dynamic> json) fromJson, {
        bool expectDataKey = true,
      }) async {
    final root = await _authedGetJson(uri);
    final payload = expectDataKey
        ? (root['data'] is Map<String, dynamic> ? root['data'] as Map<String, dynamic> : root)
        : root;
    return fromJson(payload);
  }

  // ===== Helpers =====
  static String toIso8601WithTimezone(DateTime dateTime) {
    final tz = dateTime.timeZoneOffset;
    final sign = tz.isNegative ? '-' : '+';
    String two(int n) => n.abs().toString().padLeft(2, '0');
    final hh = two(tz.inHours);
    final mm = two(tz.inMinutes.remainder(60));
    final base = dateTime.toIso8601String().split('.').first; // drop millis for API consistency
    return '$base$sign$hh:$mm';
  }

  // ===== Endpoints =====
  Future<AuspiciousPeriodModel> fetchAuspiciousPeriods({
    required int ayanamsa,
    required double latitude,
    required double longitude,
    required DateTime datetime,
    required String language,
  }) async {
    final uri = Uri.parse(ApiEndpoints.auspiciousPeriods).replace(queryParameters: {
      'ayanamsa': '$ayanamsa',
      'coordinates': '${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}',
      'datetime': toIso8601WithTimezone(datetime),
      'la': language,
    });

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
    final uri = Uri.parse(ApiEndpoints.inauspiciousPeriods).replace(queryParameters: {
      'ayanamsa': '$ayanamsa',
      'coordinates': '${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}',
      'datetime': toIso8601WithTimezone(datetime),
      'la': language,
    });

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
    final uri = Uri.parse(ApiEndpoints.panchang).replace(queryParameters: {
      'ayanamsa': '$ayanamsa',
      'coordinates': '${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}',
      'datetime': toIso8601WithTimezone(datetime),
      'la': language,
    });

    return _getWithAuthRetry<DetailedPanchangModel>(
      uri,
          (json) => DetailedPanchangModel.fromJson(json),
    );
  }

  Future<InauspiciousModel> fetchInauspiciousPeriod({
    required int ayanamsa,
    required double latitude,
    required double longitude,
    required DateTime datetime,
    required String language,
  }) async {
    final uri = Uri.parse(ApiEndpoints.inauspiciousPeriods).replace(queryParameters: {
      'ayanamsa': '$ayanamsa',
      'coordinates': '${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}',
      'datetime': toIso8601WithTimezone(datetime),
      'la': language,
    });

    return _getWithAuthRetry<InauspiciousModel>(
      uri,
          (json) => InauspiciousModel.fromJson(json),
    );
  }

  Future<PlanetPositionModel> fetchPlanetPosition({
    required int ayanamsa,
    required double latitude,
    required double longitude,
    required DateTime datetime,
    required String language,
    String? planets,
  }) async {
    // ---- Debug: input validation + logging ----
    final _sw = Stopwatch()..start();
    final supportedLangs = const {'en', 'hi', 'ta', 'te', 'ml'};
    final lang = supportedLangs.contains(language) ? language : 'en';

    if (language != lang) {
      debugPrint('⚠️ [Planet] Unsupported language "$language". '
          'Falling back to "$lang"');
    }
    if (ayanamsa < 1 || ayanamsa > 20) {
      debugPrint('⚠️ [Planet] Ayanamsa out of expected range (1–20): $ayanamsa');
    }

    final iso = toIso8601WithTimezone(datetime); // e.g. 2004-02-12T15:19:21+05:30
    final qp = <String, String>{
      'ayanamsa': '$ayanamsa',
      'coordinates':
      '${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}',
      'datetime': iso,
      'la': lang,
    };
    if (planets != null && planets.isNotEmpty) qp['planets'] = planets;

    final uri =
    Uri.parse(ApiEndpoints.planetPosition).replace(queryParameters: qp);

    debugPrint('➡️ [Planet] GET $uri');
    debugPrint('   • ayanamsa=$ayanamsa  '
        'coords=${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}');
    debugPrint('   • datetime(raw)=$datetime  datetime(iso)=$iso');
    if (planets != null && planets.isNotEmpty) {
      debugPrint('   • planets=$planets');
    }
    debugPrint('   • language=$lang');

    try {
      final root = await _authedGetJson(uri);

      // ---- Debug: shape and quick peek ----
      debugPrint('⬅️ [Planet] Response received in ${_sw.elapsedMilliseconds} ms');
      debugPrint('   • root runtimeType: ${root.runtimeType}');
      if (root is Map<String, dynamic>) {
        final keys = root.keys.take(8).join(', ');
        debugPrint('   • root keys: $keys');
        if (root.containsKey('data')) {
          debugPrint('   • found "data" key -> unwrapping');
        }
      } else if (root is List) {
        debugPrint('   • root list length: ${root.length}');
      }

      // ---- Normalize payload (unwrap common shapes) ----
      dynamic payload = root;

      // Some backends nest useful payload in "data"
      if (payload is Map<String, dynamic> && payload['data'] != null) {
        payload = payload['data'];
      }

      // Expected: { "planet_position": [ ... ] }
      if (payload is Map<String, dynamic> &&
          payload['planet_position'] is List) {
        final len = (payload['planet_position'] as List).length;
        debugPrint('✅ [Planet] planet_position list length: $len');
        _sw.stop();
        return PlanetPositionModel.fromJson(payload);
      }

      // Sometimes: bare list at root (treat as planet_position)
      if (payload is List) {
        debugPrint('✅ [Planet] Bare list payload, wrapping as planet_position '
            '(length=${payload.length})');
        _sw.stop();
        return PlanetPositionModel.fromJson({'planet_position': payload});
      }

      // Try a few alternative keys if provider changes envelopes
      if (payload is Map<String, dynamic>) {
        for (final k in const ['positions', 'result', 'response']) {
          if (payload[k] is List) {
            final len = (payload[k] as List).length;
            debugPrint('ℹ️ [Planet] Found list under "$k" (len=$len), '
                'wrapping as planet_position');
            _sw.stop();
            return PlanetPositionModel.fromJson(
                {'planet_position': payload[k]});
          }
        }
      }

      // As a last resort, emit the payload to help debugging then attempt parse
      debugPrint('❓ [Planet] Unexpected payload shape; attempting model parse…');
      _sw.stop();
      return PlanetPositionModel.fromJson(
          payload is Map<String, dynamic> ? payload : {'planet_position': payload});
    } catch (e, st) {
      _sw.stop();
      debugPrint('❌ [Planet] Request failed after '
          '${_sw.elapsedMilliseconds} ms: $e');
      debugPrint('🪵 [Planet] Stacktrace:\n$st');
      rethrow;
    }
  }

  Future<DailyPredictionModel> fetchDailyPrediction({
    required DateTime datetime,
    required String sign,
  }) async {
    final uri = Uri.parse(ApiEndpoints.dailyHoroscope).replace(queryParameters: {
      'datetime': toIso8601WithTimezone(datetime),
      'sign': sign.toLowerCase(),
    });

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
    final uri = Uri.parse(ApiEndpoints.detailedKundli).replace(queryParameters: {
      'ayanamsa': '$ayanamsa',
      'coordinates': '${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}',
      'datetime': toIso8601WithTimezone(datetime),
      'la': language,
    });

    try {
      return await _getWithAuthRetry<KundliModel>(
        uri,
            (json) => KundliModel.fromJson(json),
        expectDataKey: false, // API returns object at root
      );
    } catch (e) {
      // print('Kundli error: $e');
      return null;
    }
  }

  Future<LoveCompatibilityModel?> getLoveCompatibility({
    required String signOne,
    required String signTwo,
    required DateTime dateTime,
  }) async {
    final uri = Uri.parse(ApiEndpoints.loveCompatibility).replace(queryParameters: {
      'datetime': toIso8601WithTimezone(dateTime),
      'sign_one': signOne.toLowerCase(),
      'sign_two': signTwo.toLowerCase(),
    });

    try {
      return await _getWithAuthRetry<LoveCompatibilityModel>(
        uri,
            (json) => LoveCompatibilityModel.fromJson(json),
        expectDataKey: false,
      );
    } catch (e) {
      return null;
    }
  }

  Future<BirthdayNumberModel?> getBirthdayNumber({
    required DateTime dateTime,
  }) async {
    final uri = Uri.parse(ApiEndpoints.birthdayNumber).replace(queryParameters: {
      'datetime': toIso8601WithTimezone(dateTime),
    });

    try {
      return await _getWithAuthRetry<BirthdayNumberModel>(
        uri,
            (json) => BirthdayNumberModel.fromJson(json),
      );
    } catch (e) {
      return null;
    }
  }
}
