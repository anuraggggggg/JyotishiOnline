// lib/fastApi/agora_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AgoraVideoAuth {
  final String appId;
  final String channelName;

  // Tokens
  final String currentUserToken; // for customer
  final String astroToken;       // for astrologer

  // User accounts (MUST use for joinChannelWithUserAccount)
  final String currentUserId;    // e.g. "user_779b09..."
  final String astroId;          // e.g. "3260...."

  AgoraVideoAuth({
    required this.appId,
    required this.channelName,
    required this.currentUserToken,
    required this.astroToken,
    required this.currentUserId,
    required this.astroId,
  });

  factory AgoraVideoAuth.fromJson(Map<String, dynamic> j) {
    return AgoraVideoAuth(
      appId: j['appID'] ?? j['appId'] ?? '',
      channelName: j['channelName'] ?? '',
      currentUserToken: j['current_user_token'] ?? '',
      astroToken: j['astro_token'] ?? '',
      currentUserId: j['current_user_id'] ?? '', // ⬅️ add this
      astroId: j['astro_id'] ?? '',              // ⬅️ and this
    );
  }
}

class AgoraService {
  static const String _base = 'https://fastapi.jyotishionline.com';

  /// GET /agora/token/video?astro_id=...
  static Future<AgoraVideoAuth> getVideoTokens(String astroId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';

    final uri = Uri.parse('$_base/agora/token/video')
        .replace(queryParameters: {'astro_id': astroId});

    final res = await http.get(
      uri,
      headers: {
        'accept': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 200) {
      return AgoraVideoAuth.fromJson(jsonDecode(res.body));
    }
    throw Exception('Agora token fetch failed: ${res.statusCode} ${res.body}');
  }
}
