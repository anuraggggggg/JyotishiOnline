import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// 🔥 FCM Token (Firebase Cloud Messaging)
String? fcmToken;

/// 🧑 Current User ID (you can set this after login)
String? currentUserId;

/// 📞 Agora Credentials
const String agoraAppId = "YOUR_AGORA_APP_ID"; // ⬅️ Replace with actual App ID
String? agoraToken;  // You’ll get this dynamically from backend
String? agoraChannelName;

/// 🔐 Auth Token (if needed for API calls)
String? authToken;

/// 📲 Helper to update FCM token globally
void updateFcmToken(String token) {
  fcmToken = token;
  debugPrint("✅ FCM Token updated globally: $fcmToken");
}

/// 📲 Helper to update Agora details globally
void updateAgoraToken({
  required String token,
  required String channelName,
}) {
  agoraToken = token;
  agoraChannelName = channelName;
  debugPrint("✅ Agora Token and Channel updated globally.");
}

/// 🚀 Function to create and store FCM token
Future<void> initFcmToken() async {
  try {
    // 🔸 Request notification permissions (for iOS)
    await FirebaseMessaging.instance.requestPermission();

    // 🔸 Get the FCM token
    final token = await FirebaseMessaging.instance.getToken();

    if (token != null) {
      updateFcmToken(token);
      debugPrint("🎯 FCM Token generated and stored globally.");
    } else {
      debugPrint("⚠️ Failed to generate FCM Token.");
    }

    // 🔔 Optional: listen to token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      updateFcmToken(newToken);
      debugPrint("🔄 FCM Token refreshed.");
    });
  } catch (e) {
    debugPrint("❌ Error initializing FCM Token: $e");
  }
}
