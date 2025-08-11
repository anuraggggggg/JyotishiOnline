import 'dart:convert';
import 'package:AstrowayCustomer/fastApi/fastApiendpoints.dart';
import 'package:http/http.dart' as http;

class FastAPIServices {
  Future<http.Response> sendOtp({
    required String contactNo,
    required String countryCode,
    bool sendWhatsapp = false,
    bool sendSms = false,
  }) async {
    final url = Uri.parse(FastApiEndpoints.sendMobileOtp);

    print("🌐 Sending OTP to $contactNo ($countryCode)");
    print("📦 send_whatsapp: $sendWhatsapp, send_sms: $sendSms");

    final body = {
      "contactNo": contactNo,
      "countryCode": countryCode,
      "send_whatsapp": sendWhatsapp.toString(),
      "send_sms": sendSms.toString(),
    };

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: body, // form-url-encoded body
    );

    print("✅ Response Status: ${response.statusCode}");
    print("📩 Response Body: ${response.body}");

    return response;
  }

  Future<http.Response> verifyOtp({
    required String contactNo,
    required String countryCode,
    required String otp,
  }) async {
    final url = Uri.parse(FastApiEndpoints.verifyMobileOtp);

    print("🔍 Verifying OTP for $contactNo ($countryCode) - OTP: $otp");

    final body = {
      "contactNo": contactNo,
      "countryCode": countryCode,
      "otp": otp,
    };

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: body, // form-url-encoded body
    );

    print("✅ Response Status: ${response.statusCode}");
    print("📩 Response Body: ${response.body}");

    return response;
  }
}

