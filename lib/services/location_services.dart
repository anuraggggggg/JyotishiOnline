import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LocationService {
  static String countryCode = "IN"; // Default fallback
  static bool isIndianUser = true;  // Boolean flag

  static Future<void> detectUserCountry() async {
    String detected = "IN";

    try {
      final res = await http.get(Uri.parse("https://ipinfo.io/json"));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        detected = data["country"] ?? "IN";
      }
    } catch (_) {}

    countryCode = detected;

    // ✅ Set boolean here
    isIndianUser = detected.toUpperCase() == "IN";

    final sp = await SharedPreferences.getInstance();
    await sp.setString("user_country", detected);
    await sp.setBool("is_indian_user", isIndianUser);

    debugPrint("🌍 LocationService → Detected Country: $detected");
    debugPrint("🇮🇳 Is Indian User: $isIndianUser");
  }
}
