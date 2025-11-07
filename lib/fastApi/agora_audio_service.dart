// lib/fastApi/agora_voice_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// Use your existing video-token service
import 'agora_service.dart'; // <- provides AgoraService.getVideoTokens(...)

/// Unified model that your audio page expects.
class AgoraVoiceAuth {
  final String appId;        // e.g. "appID"
  final String channelName;  // e.g. "channelName"
  final String token;        // we will map from video tokens
  final String account;      // string userAccount to use with joinChannelWithUserAccount
  final int ttl;             // seconds (video API doesn't provide; we default 7200)

  const AgoraVoiceAuth({
    required this.appId,
    required this.channelName,
    required this.token,
    required this.account,
    required this.ttl,
  });

  Map<String, dynamic> toJson() => {
    'appId': appId,
    'channelName': channelName,
    'token': token,
    'account': account,
    'ttl': ttl,
  };

  @override
  String toString() =>
      'AgoraVoiceAuth(appId=$appId, channel=$channelName, tokenLen=${token.length}, account=$account, ttl=$ttl)';
}

/// Who is initiating the call? We need this to choose the right token/account
enum VoiceCallerRole { customer, astrologer }

class AgoraVoiceService {
  // If you still need the original voice endpoint elsewhere, keep a thin wrapper.
  // But for audio calling we’ll use the video token API via the method below.

  /// Build voice auth **using the video token API** response.
  ///
  /// - `astroId`: the astrologer’s user id (what your video API expects)
  /// - `role`: whether the caller is the customer app or the astrologer app
  /// - returns: AgoraVoiceAuth with the proper token/account mapped
  static Future<AgoraVoiceAuth> getVoiceAuthViaVideo({
    required String astroId,
    required VoiceCallerRole role,
    int fallbackTtlSeconds = 7200,
  }) async {
    // 1) Fetch the existing video tokens (single source of truth)
    final video = await AgoraService.getVideoTokens(astroId);

    // video fields you exposed:
    // appId, channelName, currentUserToken, astroToken, currentUserId, astroId

    // 2) Map to audio fields depending on role
    late final String token;
    late final String account;

    if (role == VoiceCallerRole.customer) {
      // Customer side uses "current user" credentials
      token = video.currentUserToken;
      account = video.currentUserId; // string account from server
      if (account.isEmpty) {
        // As a safe fallback, you could also use the astrologer id or "user_<something>"
        // but the preferred is the server-provided currentUserId.
        throw Exception('Video API did not return currentUserId for customer.');
      }
    } else {
      // Astrologer side uses "astro" credentials
      token = video.astroToken;
      account = video.astroId; // server provides astroId string
      if (account.isEmpty) {
        throw Exception('Video API did not return astroId for astrologer.');
      }
    }

    if (video.appId.isEmpty || video.channelName.isEmpty || token.isEmpty) {
      throw Exception('Invalid video token response (missing appId/channel/token).');
    }

    // 3) Return unified voice auth (ttl unknown from video API -> fallback)
    return AgoraVoiceAuth(
      appId: video.appId,
      channelName: video.channelName,
      token: token,
      account: account,
      ttl: fallbackTtlSeconds,
    );
  }
}
