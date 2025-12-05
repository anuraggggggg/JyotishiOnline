// lib/fastApi/agora_voice_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Model for unified voice token
class AgoraVoiceAuth {
  final String appId;
  final String channelName;
  final String token;
  final String account;
  final int ttl;

  const AgoraVoiceAuth({
    required this.appId,
    required this.channelName,
    required this.token,
    required this.account,
    required this.ttl,
  });

  Map<String, dynamic> toJson() => {
    "appId": appId,
    "channelName": channelName,
    "token": token,
    "account": account,
    "ttl": ttl,
  };

  @override
  String toString() =>
      "AgoraVoiceAuth(appId=$appId, channel=$channelName, tokenLen=${token.length}, "
          "account=$account, ttl=$ttl)";
}

class AgoraVoiceService {
  static const String baseUrl =
      "https://fastapi.jyotishionline.com/agora/token/voice";

  /// 🔥 NEW METHOD — Uses the FastAPI voice token endpoint
  static Future<AgoraVoiceAuth> getVoiceToken(String otherUserId) async {
    print("🎧[VoiceService] Requesting voice token for other_user_id=$otherUserId");

    final prefs = await SharedPreferences.getInstance();
    final bearerToken = prefs.getString("access_token") ?? "";

    final url = Uri.parse("$baseUrl?other_user_id=$otherUserId");

    print("🌐 GET → $url");
    print("🔐 [VoiceService] Loaded token from prefs (len=${bearerToken.length}): $bearerToken");

    print("🔐 Authorization → Bearer ${bearerToken.substring(0, bearerToken.length > 10 ? 10 : bearerToken.length)}...");

    final res = await http.get(
      url,
      headers: {
        "accept": "application/json",
        "Authorization": "Bearer $bearerToken",
      },
    );

    print("📥 Response status: ${res.statusCode}");
    print("📥 Raw response: ${res.body}");

    if (res.statusCode != 200) {
      throw Exception("Voice token API failed → ${res.body}");
    }

    final data = jsonDecode(res.body);

    // Validate required fields
    if (!data.containsKey("voice_token") ||
        !data.containsKey("channelName") ||
        !data.containsKey("appID") ||
        !data.containsKey("user")) {
      throw Exception("Incomplete voice token response → $data");
    }

    final auth = AgoraVoiceAuth(
      appId: data["appID"].toString(),
      channelName: data["channelName"].toString(),
      token: data["voice_token"].toString(),
      account: data["user"].toString(),
      ttl: int.tryParse(data["timer"].toString()) ?? 900,
    );

    print("✅ Voice token parsed → $auth");
    return auth;
  }
}
