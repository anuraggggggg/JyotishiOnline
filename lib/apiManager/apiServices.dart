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

/// =======================================================
/// 🔐 Prokerala Credentials Model
/// =======================================================
class ProkeralaCredentials {
  final String clientId;
  final String clientSecret;

  ProkeralaCredentials({
    required this.clientId,
    required this.clientSecret,
  });

  factory ProkeralaCredentials.fromJson(Map<String, dynamic> json) {
    return ProkeralaCredentials(
      clientId: json['client_id'],
      clientSecret: json['client_secret'],
    );
  }
}

/// =======================================================
/// 🌌 ApiService
/// =======================================================
class ApiService {
  ApiService() {
    _loadTokenFromPrefs();
  }

  // =======================================================
  // 🔐 BACKEND CREDENTIALS
  // =======================================================
  ProkeralaCredentials? _credentials;
  Future<ProkeralaCredentials>? _credentialsFuture;

  Future<ProkeralaCredentials> _fetchActiveCredentials() async {
    _credentialsFuture ??= () async {
      debugPrint('🔐 [Creds] Fetching active credentials');

      final resp = await http
          .get(
        Uri.parse(
          'https://fastapi.jyotishionline.com/api/v1/astro/get_active_credentials',
        ),
        headers: {'Accept': 'application/json'},
      )
          .timeout(const Duration(seconds: 20));

      if (resp.statusCode != 200) {
        throw Exception('Failed to fetch active credentials');
      }

      final decoded = jsonDecode(utf8.decode(resp.bodyBytes));

      if (decoded is! List || decoded.isEmpty) {
        throw Exception('No active credentials found');
      }

      final creds = ProkeralaCredentials.fromJson(decoded.first);
      _credentials = creds;

      debugPrint('✅ [Creds] client_id loaded');
      return creds;
    }();

    return _credentialsFuture!;
  }

  // =======================================================
  // 🔑 TOKEN STORAGE
  // =======================================================
  String? _accessToken;
  DateTime? _tokenExpiry;
  Future<String>? _refreshing;

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
    final expiry = DateTime.now().add(Duration(seconds: expiresInSeconds));

    await prefs.setString('pk_access_token', token);
    await prefs.setInt('pk_token_expiry', expiry.millisecondsSinceEpoch);

    _accessToken = token;
    _tokenExpiry = expiry;
  }

  bool get _tokenIsValid =>
      _accessToken != null &&
          _tokenExpiry != null &&
          DateTime.now().isBefore(
            _tokenExpiry!.subtract(const Duration(seconds: 15)),
          );

  // =======================================================
  // 🔐 FETCH PROKERALA BEARER TOKEN
  // =======================================================
  Future<String> _fetchAccessToken() async {
    final creds = _credentials ?? await _fetchActiveCredentials();

    debugPrint('🔑 [Token] Fetching Prokerala bearer token');

    final resp = await http
        .post(
      Uri.parse('https://api.prokerala.com/token'),
      headers: const {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
      },
      body: {
        'grant_type': 'client_credentials',
        'client_id': creds.clientId,
        'client_secret': creds.clientSecret,
      },
    )
        .timeout(const Duration(seconds: 20));

    if (resp.statusCode == 200) {
      final data =
      jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;

      final token = data['access_token'] as String?;
      final expiresIn = (data['expires_in'] as int?) ?? 3600;

      if (token == null) {
        throw Exception('Access token missing');
      }

      await _saveTokenToPrefs(token, expiresIn);
      debugPrint('✅ [Token] Bearer token saved');
      return token;
    }

    throw Exception(
      'Failed to fetch access token: ${resp.statusCode} ${resp.body}',
    );
  }

  Future<String> _getValidAccessToken() async {
    if (_tokenIsValid) return _accessToken!;
    _refreshing ??= _fetchAccessToken();
    try {
      return await _refreshing!;
    } finally {
      _refreshing = null;
    }
  }

  // =======================================================
  // 📡 AUTHORIZED GET
  // =======================================================
  Future<Map<String, dynamic>> _authedGetJson(
      Uri uri, {
        int retry = 0,
      }) async {
    final token = await _getValidAccessToken();

    final resp = await http
        .get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    )
        .timeout(const Duration(seconds: 25));

    if (resp.statusCode == 401 || resp.statusCode == 403) {
      if (retry > 0) {
        throw Exception('Unauthorized after refresh for ${uri.path}');
      }
      await _fetchAccessToken();
      return _authedGetJson(uri, retry: retry + 1);
    }

    if (resp.statusCode == 429) {
      if (retry >= 3) {
        throw Exception('Rate limited');
      }
      await Future.delayed(Duration(milliseconds: 500 * (1 << retry)));
      return _authedGetJson(uri, retry: retry + 1);
    }

    final decodedBody = utf8.decode(resp.bodyBytes);

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('HTTP ${resp.statusCode}: $decodedBody');
    }

    final jsonMap = jsonDecode(decodedBody);
    if (jsonMap is Map<String, dynamic>) return jsonMap;

    throw Exception('Unexpected JSON type');
  }

  Future<T> _getWithAuthRetry<T>(
      Uri uri,
      T Function(Map<String, dynamic>) fromJson, {
        bool expectDataKey = true,
      }) async {
    final root = await _authedGetJson(uri);
    final payload =
    expectDataKey && root['data'] is Map<String, dynamic>
        ? root['data']
        : root;
    return fromJson(payload);
  }

  // =======================================================
  // 🧩 HELPERS
  // =======================================================
  static String toIso8601WithTimezone(DateTime dateTime) {
    final tz = dateTime.timeZoneOffset;
    final sign = tz.isNegative ? '-' : '+';
    String two(int n) => n.abs().toString().padLeft(2, '0');
    final hh = two(tz.inHours);
    final mm = two(tz.inMinutes.remainder(60));
    final base = dateTime.toIso8601String().split('.').first;
    return '$base$sign$hh:$mm';
  }

  // =======================================================
  // 🔮 ALL API METHODS
  // =======================================================

  Future<AuspiciousPeriodModel> fetchAuspiciousPeriods({
    required int ayanamsa,
    required double latitude,
    required double longitude,
    required DateTime datetime,
    required String language,
  }) async {
    final uri =
    Uri.parse(ApiEndpoints.auspiciousPeriods).replace(queryParameters: {
      'ayanamsa': '$ayanamsa',
      'coordinates':
      '${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}',
      'datetime': toIso8601WithTimezone(datetime),
      'la': language,
    });

    return _getWithAuthRetry(uri, AuspiciousPeriodModel.fromJson);
  }

  Future<InauspiciousPeriodModel> fetchInauspiciousPeriods({
    required int ayanamsa,
    required double latitude,
    required double longitude,
    required DateTime datetime,
    required String language,
  }) async {
    final uri =
    Uri.parse(ApiEndpoints.inauspiciousPeriods).replace(queryParameters: {
      'ayanamsa': '$ayanamsa',
      'coordinates':
      '${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}',
      'datetime': toIso8601WithTimezone(datetime),
      'la': language,
    });

    return _getWithAuthRetry(uri, InauspiciousPeriodModel.fromJson);
  }

  Future<InauspiciousModel> fetchInauspiciousPeriod({
    required int ayanamsa,
    required double latitude,
    required double longitude,
    required DateTime datetime,
    required String language,
  }) async {
    final uri =
    Uri.parse(ApiEndpoints.inauspiciousPeriods).replace(queryParameters: {
      'ayanamsa': '$ayanamsa',
      'coordinates':
      '${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}',
      'datetime': toIso8601WithTimezone(datetime),
      'la': language,
    });

    return _getWithAuthRetry(uri, InauspiciousModel.fromJson);
  }

  Future<PlanetPositionModel> fetchPlanetPosition({
    required int ayanamsa,
    required double latitude,
    required double longitude,
    required DateTime datetime,
    required String language,
    String? planets,
  }) async {
    final qp = {
      'ayanamsa': '$ayanamsa',
      'coordinates':
      '${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}',
      'datetime': toIso8601WithTimezone(datetime),
      'la': language,
      if (planets != null) 'planets': planets,
    };

    final uri =
    Uri.parse(ApiEndpoints.planetPosition).replace(queryParameters: qp);

    return _getWithAuthRetry(uri, PlanetPositionModel.fromJson);
  }

  Future<DailyPredictionModel> fetchDailyPrediction({
    required DateTime datetime,
    required String sign,
  }) async {
    final uri =
    Uri.parse(ApiEndpoints.dailyHoroscope).replace(queryParameters: {
      'datetime': toIso8601WithTimezone(datetime),
      'sign': sign.toLowerCase(),
    });

    return _getWithAuthRetry(uri, DailyPredictionModel.fromJson);
  }

  Future<KundliModel?> fetchDetailedKundli({
    required int ayanamsa,
    required double latitude,
    required double longitude,
    required DateTime datetime,
    required String language,
  }) async {
    final uri =
    Uri.parse(ApiEndpoints.detailedKundli).replace(queryParameters: {
      'ayanamsa': '$ayanamsa',
      'coordinates':
      '${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}',
      'datetime': toIso8601WithTimezone(datetime),
      'la': language,
    });

    try {
      return await _getWithAuthRetry(
        uri,
        KundliModel.fromJson,
        expectDataKey: false,
      );
    } catch (_) {
      return null;
    }
  }

  Future<DetailedPanchangModel> fetchDailyPanchang({
    required int ayanamsa,
    required double latitude,
    required double longitude,
    required DateTime datetime,
    required String language,
  }) async {
    final uri = Uri.parse(ApiEndpoints.panchang).replace(
      queryParameters: {
        'ayanamsa': '$ayanamsa',
        'coordinates':
        '${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}',
        'datetime': toIso8601WithTimezone(datetime),
        'la': language,
      },
    );

    debugPrint('📡 [Panchang] GET $uri');

    return _getWithAuthRetry<DetailedPanchangModel>(
      uri,
          (json) => DetailedPanchangModel.fromJson(json),
    );
  }


  Future<LoveCompatibilityModel?> getLoveCompatibility({
    required String signOne,
    required String signTwo,
    required DateTime dateTime,
  }) async {
    final uri =
    Uri.parse(ApiEndpoints.loveCompatibility).replace(queryParameters: {
      'datetime': toIso8601WithTimezone(dateTime),
      'sign_one': signOne.toLowerCase(),
      'sign_two': signTwo.toLowerCase(),
    });

    try {
      return await _getWithAuthRetry(
        uri,
        LoveCompatibilityModel.fromJson,
        expectDataKey: false,
      );
    } catch (_) {
      return null;
    }
  }

  Future<BirthdayNumberModel?> getBirthdayNumber({
    required DateTime dateTime,
  }) async {
    final uri =
    Uri.parse(ApiEndpoints.birthdayNumber).replace(queryParameters: {
      'datetime': toIso8601WithTimezone(dateTime),
    });

    try {
      return await _getWithAuthRetry(uri, BirthdayNumberModel.fromJson);
    } catch (_) {
      return null;
    }
  }
}
