import 'package:flutter/services.dart';

class CallKitManager {
  static const MethodChannel _channel =
      MethodChannel('com.astrowaydiploy.user/channel_test');

  static Future<List<dynamic>> getActiveCalls() async {
    print("start getting getActiveCalls");

    try {
      final List<dynamic> result = await _channel.invokeMethod('activeCalls');
      return result;
    } catch (e) {
      print("Failed to get active calls: $e");
      return [];
    }
  }
}
