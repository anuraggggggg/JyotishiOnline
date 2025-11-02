// lib/fastApi/agora_voice_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AgoraVoiceAuth {
  final String appId;        // "appID"
  final String channelName;  // "channelName"
  final String token;        // "voice_token"
  final String account;      // "user" (current user id from server)
  final int ttl;             // "timer" seconds

  AgoraVoiceAuth({
    required this.appId,
    required this.channelName,
    required this.token,
    required this.account,
    required this.ttl,
  });

  factory AgoraVoiceAuth.fromJson(Map<String, dynamic> j) {
    return AgoraVoiceAuth(
      appId: (j['appID'] ?? '').toString(),
      channelName: (j['channelName'] ?? '').toString(),
      token: (j['voice_token'] ?? '').toString(),
      account: (j['user'] ?? '').toString(),
      ttl: int.tryParse('${j['timer'] ?? 0}') ?? 0,
    );
  }
}

class AgoraVoiceService {
  static const String _base = 'https://fastapi.jyotishionline.com';

  /// Call: GET /agora/token/voice?other_user_id=<astro_id>
  /// You said you'll pass ASTRO ID from both sides (customer & astrologer).
  static Future<AgoraVoiceAuth> getVoiceToken(String otherUserId) async {
    final prefs = await SharedPreferences.getInstance();
    final bearer = prefs.getString('access_token') ?? '';

    final uri = Uri.parse('$_base/agora/token/voice')
        .replace(queryParameters: {'other_user_id': otherUserId});

    final res = await http.get(
      uri,
      headers: {
        'accept': 'application/json',
        if (bearer.isNotEmpty) 'Authorization': 'Bearer $bearer',
      },
    );

    if (res.statusCode == 200) {
      return AgoraVoiceAuth.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception('Voice token fetch failed: ${res.statusCode} ${res.body}');
  }
}
