import 'dart:convert';
import 'package:AstrowayCustomer/controllers/bottomNavigationController.dart';
import 'package:AstrowayCustomer/fastApi/fastApiendpoints.dart';
import 'package:AstrowayCustomer/model/fastApiModel/CustomerDetailModel.dart';
import 'package:AstrowayCustomer/model/fastApiModel/loginResponseModel.dart';
import 'package:AstrowayCustomer/views/bottomNavigationBarScreen.dart';
import 'package:AstrowayCustomer/views/loginScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:AstrowayCustomer/utils/global.dart' as global;
import 'package:shared_preferences/shared_preferences.dart';

class FastAPIServices {
  String? _accessToken;
  String? _userId;

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");
    final userId = prefs.getString("user_id");

    if (token != null && token.isNotEmpty && userId != null) {
      print("🔐 User already logged in: $userId");
      // Navigate directly to dashboard
      final bottomNavController = Get.find<BottomNavigationController>();
      bottomNavController.setBottomIndex(0, 0);
      Get.offAll(() => BottomNavigationBarScreen(index: 0));
    } else {
      print("🛑 No saved session. Redirecting to login.");
      Get.offAll(() => LoginScreen());
    }
  }

  // ---------------- LOGIN & TOKEN ----------------
  Future<void> loginAndGetToken() async {
    final url = Uri.parse(FastApiEndpoints.login);
    print("🔑 Logging in user...");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: {
        "username": "Jincy@gmail.com",
        "password": "Jincy@12345",
      },
    );

    print("📡 Login Status: ${response.statusCode}");
    print("📩 Login Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _accessToken = data["access_token"];

      // Save token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("access_token", _accessToken!);

      print("✅ Token saved: $_accessToken");
    } else {
      throw Exception("🚨 Failed to login: ${response.body}");
    }
  }

  // ---------------- SEND OTP ----------------
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
      body: body,
    );

    print("✅ Response Status: ${response.statusCode}");
    print("📩 Response Body: ${response.body}");

    return response;
  }

  // ---------------- VERIFY OTP ----------------
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

    global.showLoader();

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: body,
    );

    global.hideLoader();

    print("✅ Response Status: ${response.statusCode}");
    print("📩 Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      // Parse with model
      final loginResponse = LoginResponse.fromJson(jsonData);

      final prefs = await SharedPreferences.getInstance();

      // Save token
      _accessToken = loginResponse.accessToken;
      if (_accessToken != null && _accessToken!.isNotEmpty) {
        await prefs.setString("access_token", _accessToken!);
      }

// Save user ID
      _userId = loginResponse.user?.id;
      if (_userId != null && _userId!.isNotEmpty) {
        await prefs.setString("user_id", _userId!);
      } else {
        print("⚠️ Warning: User ID is null or empty after parsing model.");
      }

      // Save full user details
      await prefs.setString(
        "customer_details",
        jsonEncode({
          "id": loginResponse.user.id,
          "email": loginResponse.user.email,
          "contactNo": loginResponse.user.contactNo,
        }),
      );

      // Mark as logged in
      await prefs.setBool("isLoggedIn", true);

      print("💾 Saved: isLoggedIn=true, user_id=$_userId, token=$_accessToken");

      // Navigate to dashboard
      final bottomNavController = Get.find<BottomNavigationController>();
      bottomNavController.setBottomIndex(0, 0);
      Get.offAll(() => BottomNavigationBarScreen(index: 0));
    } else {
      // Handle failure
      final errorMessage = jsonDecode(response.body)['detail'] ?? 'Invalid OTP';
      global.showToast(
        message: errorMessage,
        textColor: Colors.white,
        bgColor: Colors.red,
      );
      Get.defaultDialog(
        title: 'OTP Verification Failed',
        middleText: errorMessage,
        textConfirm: 'OK',
        onConfirm: () => Get.back(),
      );
    }

    return response;
  }

  // ---------------- FETCH CUSTOMER DETAILS ----------------
  Future<List<CustomerDetail>> fetchCustomerDetails() async {
    await _loadCredentials();

    final url = Uri.parse(FastApiEndpoints.customerDetails);
    print("🔥 [API CALL] Fetching Customer Details from $url");

    final res = await http.get(
      url,
      headers: {
        "accept": "application/json",
        "Authorization": "Bearer $_accessToken",
      },
    );

    print("📡 Status Code: ${res.statusCode}");

    if (res.statusCode == 200) {
      print("✅ 🎯 Successfully fetched customer details");
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((json) => CustomerDetail.fromJson(json)).toList();
    } else {
      throw Exception("❌ Failed to fetch customer details: ${res.body}");
    }
  }

  // ---------------- FETCH CURRENT USER DETAILS ----------------
  Future<CustomerDetail> fetchCurrentUserDetails() async {
    await _loadCredentials();

    if (_userId == null) {
      throw Exception("🚨 No user ID found in storage.");
    }

    final url = Uri.parse(FastApiEndpoints.currentUserDetails(_userId!));
    print("🔥 [API CALL] Fetching Current User Details from $url");

    final res = await http.get(
      url,
      headers: {
        "accept": "application/json",
        "Authorization": "Bearer $_accessToken",
      },
    );

    print("📡 Status Code: ${res.statusCode}");

    if (res.statusCode == 200) {
      print("✅ 🎯 Successfully fetched current user details");
      final data = jsonDecode(res.body);
      return CustomerDetail.fromJson(data);
    } else {
      throw Exception("❌ Failed to fetch current user details: ${res.body}");
    }
  }

  // ---------------- LOAD TOKEN & USER ID FROM STORAGE ----------------
  Future<void> _loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken ??= prefs.getString("access_token");
    _userId ??= prefs.getString("user_id");

    if (_accessToken == null) {
      print("⚠️ No token in memory, logging in...");
      await loginAndGetToken();
    }
  }
}
