import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  static double? _usdToInr;
  static double? _inrToUsd;

  /// 🔄 Fetch latest exchange rate
  static Future<void> fetchRates() async {
    try {
      final response = await http.get(
        Uri.parse("https://api.exchangerate-api.com/v4/latest/USD"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        _usdToInr = (data['rates']['INR'] ?? 83.0).toDouble();
        _inrToUsd = 1 / _usdToInr!;

        print("💱 USD → INR: $_usdToInr");
        print("💱 INR → USD: $_inrToUsd");
      } else {
        print("❌ Failed to fetch exchange rate");
      }
    } catch (e) {
      print("💥 Error fetching exchange rate: $e");
    }
  }

  /// 💵 Convert USD → INR
  static double usdToInr(double usdAmount) {
    if (_usdToInr == null) {
      print("⚠️ Rate not loaded, using fallback");
      return usdAmount * 83; // fallback
    }
    return usdAmount * _usdToInr!;
  }

  /// 💴 Convert INR → USD
  static double inrToUsd(double inrAmount) {
    if (_inrToUsd == null) {
      print("⚠️ Rate not loaded, using fallback");
      return inrAmount / 83; // fallback
    }
    return inrAmount * _inrToUsd!;
  }
}