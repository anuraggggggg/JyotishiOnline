import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static String countryCode = "IN"; // Default fallback

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

    final sp = await SharedPreferences.getInstance();
    await sp.setString("user_country", detected);

    // Debug log
    debugPrint("🌍 LocationService → Detected Country: $detected");
  }


  static bool get isIndia => countryCode == "IN";
}
