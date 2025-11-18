import 'package:agora_rtm/agora_rtm.dart';
import 'package:flutter/material.dart';

class AgoraRtmService {
  static AgoraRtmClient? client;
  static AgoraRtmChannel? channel;

  // Initialize RTM Engine
  static Future<void> init(String appId) async {
    client = await AgoraRtmClient.createInstance(appId);

    client?.onConnectionStateChanged = (state, reason) {
      debugPrint("RTM Connection: state=$state reason=$reason");
      if (state == 5) {
        client?.logout();
      }
    };
  }

  // Login with UID
  static Future<void> login(String uid) async {
    try {
      await client?.login(null, uid);
      debugPrint("RTM Login success: $uid");
    } catch (e) {
      debugPrint("RTM Login failed: $e");
    }
  }

  // Join RTM Channel
  static Future<void> joinChannel(
      String name,
      Function(String user, String text) onMessage,
      ) async {
    try {
      channel = await client?.createChannel(name);

      channel?.onMessageReceived = (msg, member) {
        onMessage(member.userId, msg.text);
      };

      await channel?.join();
      debugPrint("RTM Channel Joined: $name");
    } catch (e) {
      debugPrint("RTM joinChannel failed: $e");
    }
  }

  // Send Message to Channel
  static Future<void> send(String text) async {
    try {
      await channel?.sendMessage(AgoraRtmMessage.fromText(text));
      debugPrint("RTM Message sent: $text");
    } catch (e) {
      debugPrint("RTM send failed: $e");
    }
  }

  // Cleanup
  static Future<void> logout() async {
    try {
      await channel?.leave();
    } catch (_) {}

    try {
      await client?.logout();
    } catch (_) {}
  }
}
