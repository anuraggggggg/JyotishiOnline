// lib/fastApi/agora_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// --------------------------------------
/// UNIVERSAL AGORA TOKEN MODEL
/// For BOTH Audio + Video calls.
/// --------------------------------------
class AgoraAuth {
  final String appId;
  final String channelName;

  final String astroId;
  final String astroToken;

  final String currentUserId;
  final String currentUserToken;

  final int expireIn;

  AgoraAuth({
    required this.appId,
    required this.channelName,
    required this.astroId,
    required this.astroToken,
    required this.currentUserId,
    required this.currentUserToken,
    required this.expireIn,
  });

  factory AgoraAuth.fromJson(Map<String, dynamic> j) {
    return AgoraAuth(
      appId: (j['appID'] ?? j['appId'] ?? "").toString(),
      channelName: (j['channelName'] ?? "").toString(),
      astroId: (j['astro_id'] ?? "").toString(),
      astroToken: (j['astro_token'] ?? "").toString(),
      currentUserId: (j['current_user_id'] ?? "").toString(),
      currentUserToken: (j['current_user_token'] ?? "").toString(),
      expireIn: j['expireIn'] ?? 900,
    );
  }
}

/// --------------------------------------
/// AGORA SERVICE (Unified)
/// --------------------------------------
class AgoraService {
  static const String _base = 'https://fastapi.jyotishionline.com';

  /// GET /agora/token/video → UNIVERSAL TOKEN FOR AUDIO + VIDEO
  static Future<AgoraAuth> getTokens(String astroId) async {
    final prefs = await SharedPreferences.getInstance();
    final bearer = prefs.getString("access_token") ?? "";

    final uri = Uri.parse("$_base/agora/token/video")
        .replace(queryParameters: {"astro_id": astroId});

    final res = await http.get(
      uri,
      headers: {
        "accept": "application/json",
        if (bearer.isNotEmpty) "Authorization": "Bearer $bearer",
      },
    );

    if (res.statusCode != 200) {
      throw Exception(
          "Failed to fetch universal Agora token: ${res.statusCode} ${res.body}");
    }

    return AgoraAuth.fromJson(jsonDecode(res.body));
  }

  /// Convert model to actual Agora join params
  static Map<String, String> buildJoinParams({
    required AgoraAuth auth,
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
