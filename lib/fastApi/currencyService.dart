import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {

  /// 💱 Convert INR → USD (from your backend)
  static Future<double> inrToUsd(double inrAmount) async {
    try {
      final url =
          "https://fastapi.jyotishionline.com/api/v1/auth/convert?amount=$inrAmount";

      print("🌍 API Call → $url");

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        double usd = (data["usd_value"] ?? 0).toDouble();

        print("💱 Converted: ₹$inrAmount → \$$usd");

        return usd;
      } else {
        print("❌ API Error: ${response.statusCode}");
        return inrAmount / 83; // fallback
      }
    } catch (e) {
      print("💥 Conversion error: $e");
      return inrAmount / 83; // fallback
    }
  }
}