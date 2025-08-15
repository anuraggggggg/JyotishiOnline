import 'dart:async';
import 'dart:convert';
import 'package:AstrowayCustomer/controllers/bottomNavigationController.dart';
import 'package:AstrowayCustomer/fastApi/fastApiendpoints.dart';
import 'package:AstrowayCustomer/model/fastApiModel/CustomerDetailModel.dart';
import 'package:AstrowayCustomer/model/fastApiModel/UserModel.dart';
import 'package:AstrowayCustomer/model/fastApiModel/allWalletDeatilsModel.dart';
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

  // ---------------- LOGIN WITH EMAIL ----------------
  Future<void> loginWithEmail({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(FastApiEndpoints.login),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final accessToken = responseData['access_token'];
        final userJson = responseData['user'];

        // Parse user into UserModel
        final user = UserModel.fromJson(userJson);

        // Save token and user ID
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("access_token", accessToken);
        await prefs.setString("user_id", user.id);

        // Print full user details
        print("===== 👤 USER DETAILS =====");
        print("🆔 ID         : ${user.id}");
        print("📛 Name       : ${user.name}");
        print("📧 Email      : ${user.email}");
        print("📱 Contact No : ${user.contactNo}");
        print("🚻 Gender     : ${user.gender}");
        print("🕒 Last Seen  : ${user.lastSeen}");
        print("🔑 AccessToken: $accessToken");
        print("===========================");

        Get.snackbar(
          'Success',
          'Welcome, ${user.name}!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        final bottomNavController = Get.find<BottomNavigationController>();
        bottomNavController.setBottomIndex(0, 0);
        Get.offAll(() => BottomNavigationBarScreen(index: 0));
      } else if (response.statusCode == 422) {
        final responseData = jsonDecode(response.body);
        final details = responseData['detail'] as List;
        final errorMessage = details.isNotEmpty
            ? details.first['msg']
            : 'Invalid email or password.';

        print('Validation Error: $errorMessage');
        Get.snackbar(
          'Error',
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } else {
        print('HTTP Error: ${response.statusCode}');
        print('Response Body: ${response.body}');
        Get.snackbar(
          'Error',
          'Login failed. Please check your credentials.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Network Error: $e');
      Get.snackbar(
        'Error',
        'Failed to connect to the server. Please check your internet connection.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ---------------- LOGOUT ----------------
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Remove all login-related keys
      await prefs.remove("access_token");
      await prefs.remove("user_id");
      await prefs.remove("customer_details");
      await prefs.remove("isLoggedIn");

      // Clear local variables
      _accessToken = null;
      _userId = null;

      print("✅ User logged out successfully. SharedPreferences cleared.");

      // Navigate to the login screen and clear the navigation stack
      Get.offAll(() => LoginScreen());
    } catch (e) {
      print("❌ Failed to log out: $e");
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
      final customers =
          data.map((json) => CustomerDetail.fromJson(json)).toList();

      // Print all customer details
      print("📋 All Customers:");
      for (var i = 0; i < customers.length; i++) {
        final c = customers[i];
        print("🔹 Customer ${i + 1}:");
        print(" 🐛 Birth Date     : ${c.birthDate}");
        print("  🐛 Birth Time     : ${c.birthTime}");
        print("  🐛 Profile        : ${c.profile}");
        print("  🐛 Birth Place    : ${c.birthPlace}");
        print("  🐛 Address 1      : ${c.addressLine1}");
        print("  🐛 Address 2      : ${c.addressLine2}");
        print("  🐛 Location       : ${c.location}");
        print("  🐛 Pincode        : ${c.pincode}");
        print("  🐛 Gender         : ${c.gender}");
        // print("  Token            : ${c.token}");
        print("  🐛 Country Code   : ${c.countryCode}");
        print("  🐛 Created At     : ${c.createdAt}");
        print("  🐛 Updated At     : ${c.updatedAt}");
        print("  🐛 Active         : ${c.isActive}");
        print("  🐛 Deleted        : ${c.isDelete}");
        print("─────────────────────────────");
      }

      return customers;
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

    _accessToken = prefs.getString("access_token");
    _userId = prefs.getString("user_id");

    print("🔑 Loaded token: $_accessToken");
    print("👤 Loaded userId: $_userId");

    bool needsLogin = false;

    if (_accessToken == null) {
      print("⚠️ No token found.");
      needsLogin = true;
    } else if (_isTokenExpired(_accessToken!)) {
      print("⚠️ Token expired.");
      needsLogin = true;
    }

    if (_userId == null) {
      print("⚠️ No user ID found.");
      needsLogin = true;
    }

    if (needsLogin) {
      print("🔄 Logging in to refresh credentials...");
      await loginAndGetToken();
    }
  }

  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );

      final exp = payload['exp'] as int;
      final expiryDate =
          DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
      final now = DateTime.now().toUtc();

      print("⏳ Token expiry date (UTC): $expiryDate");
      return expiryDate.isBefore(now);
    } catch (e) {
      print("❌ Token parse error: $e");
      return true; // treat as expired if invalid format
    }
  }

  // -------------------- Fetch All Wallets --------------------
  Future<List<WalletModel>> getAllWalletDetails() async {
    await _loadCredentials();

    final url = Uri.parse(FastApiEndpoints.allWalletDetails);
    print("💰 [API CALL] Fetching All Wallet Details from $url");

    final headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer $_accessToken',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final wallets = data.map((json) => WalletModel.fromJson(json)).toList();
      print("💰 Successfully fetched ${wallets.length} wallets");
      return wallets;
    } else if (response.statusCode == 401) {
      print("⚠️ Token invalid or expired. Please login again.");
      throw Exception("Unauthorized: Invalid token");
    } else {
      print("⚠️ Failed to fetch wallets: ${response.statusCode}");
      print("Response Body: ${response.body}");
      throw Exception("Failed to fetch wallets");
    }
  }
}
