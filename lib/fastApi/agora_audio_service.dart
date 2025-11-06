// lib/fastApi/agora_voice_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AgoraVoiceAuth {
  final String appId;        // e.g. "appID" / "appId"
  final String channelName;  // e.g. "channelName" / "channel"
  final String? token;       // e.g. "voice_token" / "rtcToken" / "token" (nullable)
  final String account;      // e.g. "user" / "account"
  final int ttl;             // e.g. "timer" / "expiresIn" (seconds)

  const AgoraVoiceAuth({
    required this.appId,
    required this.channelName,
    required this.token,
    required this.account,
    required this.ttl,
  });

  // Flexible JSON reader (handles multiple possible key names)
  static String _readStr(Map<String, dynamic> j, List<String> keys) {
    for (final k in keys) {
      final v = j[k];
      if (v != null) return v.toString();
    }
    return '';
  }

  static int _readInt(Map<String, dynamic> j, List<String> keys) {
    for (final k in keys) {
      final v = j[k];
      if (v is int) return v;
      if (v is String) {
        final n = int.tryParse(v);
        if (n != null) return n;
      }
    }
    return 0;
  }

  factory AgoraVoiceAuth.fromJson(Map<String, dynamic> j) {
    final appId = _readStr(j, ['appID', 'appId']);
    final channel = _readStr(j, ['channelName', 'channel']);
    // token can be under different keys or absent when certificates are disabled
    final rawToken = _readStr(j, ['voice_token', 'rtcToken', 'token']);
    final acct = _readStr(j, ['user', 'account']);
    final ttl = _readInt(j, ['timer', 'expiresIn']);

    if (appId.isEmpty || channel.isEmpty) {
      throw const FormatException('Invalid voice auth: appId/channelName missing');
    }

    return AgoraVoiceAuth(
      appId: appId,
      channelName: channel,
      token: rawToken.isNotEmpty ? rawToken : null,
      account: acct,
      ttl: ttl,
    );
  }

  Map<String, dynamic> toJson() => {
    'appId': appId,
    'channelName': channelName,
    'token': token,
    'account': account,
    'ttl': ttl,
  };

  @override
  String toString() =>
      'AgoraVoiceAuth(appId=$appId, channel=$channelName, hasToken=${token != null}, account=$account, ttl=$ttl)';
}

class AgoraVoiceService {
  static const String _base = 'https://fastapi.jyotishionline.com';

  /// GET /agora/token/voice
  ///
  /// Backend variance: sometimes expects `other_user_id`, sometimes `astro_id`.
  /// We include both; server should pick whichever it supports.
  static Future<AgoraVoiceAuth> getVoiceToken({
    required String otherUserId,
    String? astroId,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final bearer = prefs.getString('access_token');

    final qp = <String, String>{
      'other_user_id': otherUserId,
      'astro_id': astroId ?? otherUserId,
    };

    final uri = Uri.parse('$_base/agora/token/voice').replace(queryParameters: qp);

    final headers = <String, String>{
      'accept': 'application/json',
      if (bearer != null && bearer.isNotEmpty) 'Authorization': 'Bearer $bearer',
    };

    http.Response res;
    try {
      res = await http.get(uri, headers: headers).timeout(timeout);
    } on SocketException {
      throw Exception('Network error: unable to reach server');
    } on HttpException catch (e) {
      throw Exception('HTTP error: $e');
    } on FormatException {
      throw Exception('Bad response from server');
    } on TimeoutException {
      throw Exception('Request timed out');
    }

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return AgoraVoiceAuth.fromJson(body);
    }

    if (res.statusCode == 401) {
      throw Exception('Unauthorized (401). Please log in again.');
    }

    throw Exception('Voice token fetch failed: ${res.statusCode} ${res.body}');
  }

  /// Optional: deterministic local channel helper (usually not needed).
  static String buildDeterministicChannel(
      String a,
      String b, {
        String prefix = 'vc_',
      }) {
    final x = a.trim();
    final y = b.trim();
    if (x.isEmpty || y.isEmpty) {
      return '$prefix${DateTime.now().millisecondsSinceEpoch}';
    }
    final ordered = [x, y]..sort();
    String shrink(String s) => s.substring(0, s.length.clamp(0, 12));
    return '$prefix${shrink(ordered[0])}${shrink(ordered[1])}';
  }
}
