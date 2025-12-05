// lib/fastApi/agora_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// --------------------------------------
/// MODEL FOR VIDEO API
/// --------------------------------------
class AgoraVideoAuth {
  final String appId;
  final String channelName;
  final String astroId;
  final String astroToken;
  final String currentUserId;
  final String currentUserToken;
  final int expireIn;

  AgoraVideoAuth({
    required this.appId,
    required this.channelName,
    required this.astroId,
    required this.astroToken,
    required this.currentUserId,
    required this.currentUserToken,
    required this.expireIn,
  });

  factory AgoraVideoAuth.fromJson(Map<String, dynamic> j) {
    return AgoraVideoAuth(
      appId: j['appID'] ?? "",
      channelName: j['channelName'] ?? "",
      astroId: j['astro_id'] ?? "",
      astroToken: j['astro_token'] ?? "",
      currentUserId: j['current_user_id'] ?? "",
      currentUserToken: j['current_user_token'] ?? "",
      expireIn: j['expireIn'] ?? 900,
    );
  }
}

/// --------------------------------------
/// MODEL FOR VOICE API
/// --------------------------------------
class VoiceTokenResponse {
  final String appId;
  final String channelName;
  final String token;
  final String userAccount;
  final int duration;

  VoiceTokenResponse({
    required this.appId,
    required this.channelName,
    required this.token,
    required this.userAccount,
    required this.duration,
  });

  factory VoiceTokenResponse.fromJson(Map<String, dynamic> j) {
    return VoiceTokenResponse(
      appId: j["appID"] ?? "",
      channelName: j["channelName"] ?? "",
      token: j["voice_token"] ?? "",
      userAccount: j["user"] ?? "",
      duration: j["timer"] ?? 900,
    );
  }
}

/// --------------------------------------
/// AGORA SERVICE
/// --------------------------------------
class AgoraService {
  static const String _base = 'https://fastapi.jyotishionline.com';

  /// -----------------------------
  /// 🔥 AUDIO CALL TOKEN API
  /// -----------------------------
  static Future<VoiceTokenResponse> getVoiceToken(String otherUserId) async {
    final prefs = await SharedPreferences.getInstance();
    final bearer = prefs.getString("access_token") ?? "";

    final uri = Uri.parse("$_base/agora/token/voice")
        .replace(queryParameters: {"other_user_id": otherUserId});

    final res = await http.get(
      uri,
      headers: {
        "accept": "application/json",
        if (bearer.isNotEmpty) "Authorization": "Bearer $bearer",
      },
    );

    if (res.statusCode != 200) {
      throw Exception(
          "Voice token API failed: ${res.statusCode} ${res.body}");
    }

    return VoiceTokenResponse.fromJson(jsonDecode(res.body));
  }

  /// -----------------------------
  /// 🎥 VIDEO CALL TOKEN API
  /// -----------------------------
  static Future<AgoraVideoAuth> getVideoTokens(String astroId) async {
    final prefs = await SharedPreferences.getInstance();
    final bearer = prefs.getString('access_token') ?? '';

    final uri = Uri.parse('$_base/agora/token/video')
        .replace(queryParameters: {'astro_id': astroId});

    final res = await http.get(
      uri,
      headers: {
        'accept': 'application/json',
        if (bearer.isNotEmpty) 'Authorization': 'Bearer $bearer',
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Video token fetch failed: ${res.statusCode} ${res.body}');
    }

    return AgoraVideoAuth.fromJson(jsonDecode(res.body));
  }

  /// -----------------------------
  /// 🎯 BUILDER FOR VIDEO CALL
  /// -----------------------------
  static Map<String, String> buildVideoJoin({
    required AgoraVideoAuth auth,
    required bool isAstrologer,
  }) {
    return {
      "appId": auth.appId,
      "channel": auth.channelName,
      "token": isAstrologer ? auth.astroToken : auth.currentUserToken,
      "account": isAstrologer ? auth.astroId : auth.currentUserId,
    };
  }
}
