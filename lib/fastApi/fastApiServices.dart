import 'dart:async';
import 'dart:convert';
import 'package:AstrowayCustomer/controllers/bottomNavigationController.dart';
import 'package:AstrowayCustomer/fastApi/fastApiendpoints.dart';
import 'package:AstrowayCustomer/model/fastApiModel/CustomerDetailModel.dart';
import 'package:AstrowayCustomer/model/fastApiModel/UserModel.dart';
import 'package:AstrowayCustomer/model/fastApiModel/allWalletDeatilsModel.dart';
import 'package:AstrowayCustomer/model/fastApiModel/currentUserWalletModel.dart';
import 'package:AstrowayCustomer/model/fastApiModel/loginResponseModel.dart';
import 'package:AstrowayCustomer/views/bottomNavigationBarScreen.dart';
import 'package:AstrowayCustomer/views/loginScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:AstrowayCustomer/utils/global.dart' as global;
import 'package:shared_preferences/shared_preferences.dart';

import '../model/fastApiModel/NotificationModel.dart';
import '../model/fastApiModel/astrologerProfileModel.dart';

class FastAPIServices {
  String? _accessToken;
  String? _userId;

  String? get userId => _userId;
  String? get accessToken => _accessToken;

  // ---------------- FETCH CUSTOMER NOTIFICATIONS ----------------
  // Helper to load credentials
  // Future<Map<String, String?>> _loadCredentials() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final userId = prefs.getString("user_id");
  //   final accessToken = prefs.getString("access_token");
  //
  //   print("🔑 _loadCredentials() -> userId: $userId, accessToken: $accessToken");
  //
  //   return {
  //     'userId': userId,
  //     'accessToken': accessToken,
  //   };
  // }

// Updated fetch function using _loadCredentials()
  Future<List<NotificationModel>> fetchCustomerNotifications() async {
    print("🚀 Starting fetchCustomerNotifications");

    // Load credentials
    await _loadCredentials(); // this sets _userId and _accessToken
    print("🔑 Loaded userId: $_userId");
    print("🔑 Loaded accessToken: $_accessToken");

    if (_userId == null || _accessToken == null) {
      print("❌ UserId or AccessToken is null, throwing credential exception");
      // Throwing an exception when credentials are not available
      throw Exception('Authentication credentials missing. Please log in.');
    }

    // NOTE: Assuming the correct URL is ${FastApiEndpoints.fastApiBaseUrl}/api/v1/notifications/$_userId
    // The original URL was just /api/v1/$_userId, which may be incorrect for a notifications endpoint.
    // Using the original URL for now:
    final url = Uri.parse("${FastApiEndpoints.fastApiBaseUrl}/api/v1/$_userId");
    print("🌐 Fetching notifications from: $url");

    try {
      final response = await http.get(
        url,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
      );

      print("📩 Response status: ${response.statusCode}");
      print("📩 Response body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print("✅ Successfully fetched ${data.length} notifications.");
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      } else {
        // ❌ Throw descriptive exception for non-200 status codes
        print("❌ Failed to fetch notifications, status code: ${response.statusCode}");
        throw Exception(
          'API call failed: Status ${response.statusCode}. Body: ${response.body}',
        );
      }
    } catch (e) {
      // ❌ Re-throw network/decoding exceptions
      print("❌ Error fetching notifications: $e");
      throw Exception('Network or decoding error while fetching notifications: $e');
    }
  }








  /// Block or report an astrologer with full debug
  /// ✅ Block an astrologer (Final Version)
  Future<Map<String, dynamic>?> blockAstrologer({

    required String astrologerId,
  }) async {
    await _loadCredentials();
    final url = Uri.parse("${FastApiEndpoints.fastApiBaseUrl}/api/v1/block/block");

    print("📌 URL: $url");

    final headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $accessToken", // Make sure this is set
    };

    final body = {
      "astrologerId": astrologerId,
    };

    print("📌 Headers: $headers");
    print("📌 Body: ${jsonEncode(body)}");

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      print("📌 Status Code: ${response.statusCode}");
      print("📌 Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Astrologer blocked successfully");
        return jsonDecode(response.body);
      } else {
        print("❌ Error: ${response.statusCode} -> ${response.body}");
        return null;
      }
    } catch (e) {
      print("⚠️ Exception in blockAstrologer(): $e");
      return null;
    }
  }
  /// Block or report an astrologer with full debug
  Future<Map<String, dynamic>?> reportAstrologer({
    required String astrologerId,
    String? reason,
  }) async {
    await _loadCredentials(); // ensures _userId and _accessToken are set

    if (_accessToken == null) {
      print("❌ Missing credentials: accessToken=$_accessToken");
      return null;
    }

    final url = Uri.parse(FastApiEndpoints.reportAstrologer);

    // Correct body with camelCase field names
    final body = {
      "astrologerId": astrologerId, // camelCase
      "reason": reason ?? "",
    };

    print("📌 URL: $url");
    print("📌 Headers: ${{
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $_accessToken",
    }}");
    print("📌 Body: ${jsonEncode(body)}");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $_accessToken",
        },
        body: jsonEncode(body),
      );

      print("📌 Status Code: ${response.statusCode}");
      print("📌 Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Astrologer reported successfully");
        return jsonDecode(response.body);
      } else {
        print("❌ Error: ${response.statusCode} -> ${response.body}");
        return null;
      }
    } catch (e) {
      print("⚠️ Exception in reportAstrologer(): $e");
      return null;
    }
  }





  // ---------------- CHECK LOGIN STATUS ----------------
  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");
    final userId = prefs.getString("user_id");

    if (token != null && token.isNotEmpty && userId != null) {
      print("🔐 User already logged in: $userId");
      final bottomNavController = Get.find<BottomNavigationController>();
      bottomNavController.setBottomIndex(0, 0);
      Get.offAll(() => BottomNavigationBarScreen(index: 0));
    } else {
      print("🛑 No saved session. Redirecting to login.");
      Get.offAll(() => LoginScreen());
    }
  }

  // ---------------- FETCH ASTROLOGER DETAIL BY ID ----------------
  Future<Astrologer> fetchAstrologerDetail(String astroId) async {
    await _loadCredentials();

    if (_accessToken == null) {
      throw Exception("🚨 Access token is missing. Please login again.");
    }

    final url = Uri.parse("${FastApiEndpoints.astrologerById}$astroId");

    // 🟢 Debug prints
    print("🔮 [API CALL] Fetching astrologer detail");
    print("🆔 Astro ID: $astroId");
    print("🌐 URL: $url");
    print("🔑 Access Token: $_accessToken");
    print("📝 Headers: ${{
      "accept": "application/json",
      "Authorization": "Bearer $_accessToken",
    }}");

    final response = await http.get(
      url,
      headers: {
        "accept": "application/json",
        "Authorization": "Bearer $_accessToken",
      },
    );

    // 🟢 Debug response
    print("📡 Status Code: ${response.statusCode}");
    print("📩 Response Body: ${response.body}");

    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (decoded is Map<String, dynamic>) {
        print("✅ Astrologer fetched successfully");
        print("🆔 ID: ${decoded['astro_id']}");
        print("👤 Name: ${decoded['name']}");
        print("🖼 Profile Image: ${decoded['profileImage']}");
        print("✨ Primary Skill: ${decoded['primarySkill']}");
        print("🗣 Languages: ${decoded['languageKnown']}");
        print("📆 Experience: ${decoded['experienceInYears']}");
        print("💰 Charge: ${decoded['charge']}");
        print("🏙 Current City: ${decoded['currentCity']}");
        return Astrologer.fromJson(decoded);
      } else if (decoded is List) {
        throw Exception("Astrologer not found. Response: $decoded");
      } else {
        throw Exception("Unexpected response format: $decoded");
      }
    } else if (response.statusCode == 404) {
      throw Exception("Astrologer not found. ID: $astroId");
    } else {
      throw Exception("Failed to fetch astrologer: ${response.body}");
    }
  }





  // A method to fetch wallet transactions
  Future<List<dynamic>> getWalletTransactions() async {
    await _loadCredentials(); // ✅ Ensure token & userId are loaded first
    // Ensure both the user ID and access token are available
    if (_userId == null || _accessToken == null) {
      throw Exception('User ID or Access Token is not set.');
    }

    final url = Uri.parse('${FastApiEndpoints.walletTransactions}$_userId');

    // 2. Make the GET request
    final response = await http.get(
      url,
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $_accessToken',
      },
    );

    // 3. Handle the response
    if (response.statusCode == 200) {
      // Decode the JSON response body
      final List<dynamic> transactions = json.decode(response.body);
      return transactions;
    } else {
      // Throw an exception for a non-200 status code
      throw Exception(
          'Failed to load wallet transactions. Status code: ${response.statusCode}');
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

        final user = UserModel.fromJson(userJson);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("access_token", accessToken);
        await prefs.setString("user_id", user.id);
        await prefs.setString("user_name", user.name);

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

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("user_name");
  }

  /// Update the current user's profile
  static Future<bool> updateUserProfile({
    required String userId,
    required String accessToken,
    required Map<String, dynamic> updatedData,
  }) async {
    final url = Uri.parse("${FastApiEndpoints.customerDetails}$userId");

    try {
      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
        body: jsonEncode(updatedData),
      );

      if (response.statusCode == 200) {
        print("✅ Profile updated successfully");
        return true;
      } else {
        print("❌ Failed to update profile: ${response.body}");
        return false;
      }
    } catch (e) {
      print("⚠️ Error updating profile: $e");
      return false;
    }
  }



  // ---------------- FETCH ALL ASTROLOGERS ----------------
  Future<List<dynamic>> fetchAllAstrologers() async {
    await _loadCredentials(); // Load token

    final url = Uri.parse(FastApiEndpoints.allAstrologers);
    print("🔮 [API CALL] Fetching all astrologers from $url");

    final response = await http.get(
      url,
      headers: {
        "accept": "application/json",
        "Authorization": "Bearer ${_accessToken}",
      },
    );

    print("📡 Status Code: ${response.statusCode}");
    print("📩 Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      print("🧙‍♂️ Total Astrologers Fetched: ${data.length}");

      for (var astro in data) {
        print("""
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔮 ASTROLOGER DETAILS
🆔 ID: ${astro['astro_id']}
👤 Name: ${astro['name']}
🖼 Profile Image: ${astro['profileImage']}
✨ Primary Skill: ${astro['primarySkill']}
🗣 Languages: ${astro['languageKnown']}
📆 Experience: ${astro['experienceInYears']} years
💰 Charge: ₹${astro['charge']} per min
🏙 Current City: ${astro['currentCity']}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
""");
      }

      return data;
    } else if (response.statusCode == 401) {
      throw Exception("🚨 Unauthorized. Please login again.");
    } else {
      throw Exception("❌ Failed to fetch astrologers: ${response.body}");
    }
  }

  // ---------------- LOGOUT ----------------
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove("access_token");
      await prefs.remove("user_id");
      await prefs.remove("customer_details");
      await prefs.remove("isLoggedIn");

      _accessToken = null;
      _userId = null;

      print("✅ User logged out successfully. SharedPreferences cleared.");

      Get.offAll(() => LoginScreen());
    } catch (e) {
      print("❌ Failed to log out: $e");
    }
  }

  // ---------------- LOGIN & TOKEN ----------------
  Future<void> loginAndGetToken() async {
    final url = Uri.parse(FastApiEndpoints.login);
    print("🔑 Logging in user (for re-authentication)...");

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

      // 1. Set Access Token
      _accessToken = data["access_token"];

      // 2. CRITICAL FIX: Extract and set the User ID
      // Assuming the user object is nested in the response under the key 'user'
      final userJson = data["user"];
      if (userJson != null) {
        final user = UserModel.fromJson(userJson); // Assuming UserModel is available
        _userId = user.id; // ✅ FIX: Set the class property _userId
      }

      final prefs = await SharedPreferences.getInstance();

      // 3. Save both credentials to SharedPreferences
      if (_accessToken != null) {
        await prefs.setString("access_token", _accessToken!);
      }
      if (_userId != null) {
        await prefs.setString("user_id", _userId!); // ✅ FIX: Save user_id to storage
      }

      print("✅ Token and UserId saved after re-login: $_accessToken, $_userId");
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
      final loginResponse = LoginResponse.fromJson(jsonData);

      final prefs = await SharedPreferences.getInstance();

      _accessToken = loginResponse.accessToken;
      if (_accessToken != null && _accessToken!.isNotEmpty) {
        await prefs.setString("access_token", _accessToken!);
      }

      _userId = loginResponse.user?.id;
      if (_userId != null && _userId!.isNotEmpty) {
        await prefs.setString("user_id", _userId!);
      } else {
        print("⚠️ Warning: User ID is null or empty after parsing model.");
      }

      await prefs.setString(
        "customer_details",
        jsonEncode({
          "id": loginResponse.user.id,
          "email": loginResponse.user.email,
          "contactNo": loginResponse.user.contactNo,
        }),
      );

      await prefs.setBool("isLoggedIn", true);

      print("💾 Saved: isLoggedIn=true, user_id=$_userId, token=$_accessToken");

      final bottomNavController = Get.find<BottomNavigationController>();
      bottomNavController.setBottomIndex(0, 0);
      Get.offAll(() => BottomNavigationBarScreen(index: 0));
    } else {
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

    try {
      final res = await http.get(
        url,
        headers: {
          "accept": "application/json",
          "Authorization": "Bearer $_accessToken",
        },
      );

      print("📡 Status Code: ${res.statusCode}");
      print("📝 Raw Response Body ↓\n${res.body}");

      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);

        print("✅ 🎯 Successfully fetched customer details");
        print("👥 Total Customers Fetched: ${data.length}");

        // Pretty print each customer JSON for clarity
        for (int i = 0; i < data.length; i++) {
          final prettyJson = const JsonEncoder.withIndent('  ').convert(data[i]);
          print("📌 Customer $i:\n$prettyJson");
        }

        final customers = data.map((json) => CustomerDetail.fromJson(json)).toList();
        return customers;
      } else {
        print("❌ Failed to fetch customer details: ${res.body}");
        throw Exception("Failed to fetch customer details: ${res.body}");
      }
    } catch (e, stack) {
      print("🚨 Exception while fetching customer details: $e");
      print("🧾 StackTrace: $stack");
      rethrow;
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

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return CustomerDetail.fromJson(data);
    } else {
      throw Exception("❌ Failed to fetch current user details: ${res.body}");
    }
  }

  // ---------------- LOAD TOKEN & USER ID FROM STORAGE ----------------
// ---------------- LOAD TOKEN & USER ID FROM STORAGE (REFINED) ----------------
  Future<void> _loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();

    // Always attempt to load from storage first
    _accessToken = prefs.getString("access_token");
    _userId = prefs.getString("user_id");

    bool needsLogin = false;

    if (_accessToken == null) {
      needsLogin = true;
    } else if (_isTokenExpired(_accessToken!)) {
      needsLogin = true;
    }

    // The re-login logic is now robust enough to handle _userId being null,
    // so we keep the check here to trigger the login flow.
    if (_userId == null) {
      needsLogin = true;
    }

    if (needsLogin) {
      await loginAndGetToken(); // This now correctly sets _userId and _accessToken

      // Safety check: Re-read values just in case loginAndGetToken succeeded
      // but didn't update the properties correctly (or read the ID from storage)
      if (_userId == null) {
        _accessToken = prefs.getString("access_token");
        _userId = prefs.getString("user_id");
      }
    }

    print("✅ _loadCredentials() completed -> _userId=$_userId, _accessToken=${_accessToken != null ? 'LOADED' : 'NULL'}");
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
      return expiryDate.isBefore(now);
    } catch (e) {
      return true;
    }
  }

  // ---------------- Fetch All Wallets ----------------
  Future<List<WalletModel>> getAllWalletDetails() async {
    await _loadCredentials();

    final url = Uri.parse(FastApiEndpoints.allWalletDetails);

    final headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer $_accessToken',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final wallets = data.map((json) => WalletModel.fromJson(json)).toList();
      return wallets;
    } else {
      throw Exception("Failed to fetch wallets: ${response.body}");
    }
  }

  // ---------------- Fetch Current User Wallet ----------------
  Future<CurrentUserWalletModel?> fetchCurrentWallet() async {
    await _loadCredentials();

    if (_userId == null || _accessToken == null) {
      return null;
    }

    final url = "${FastApiEndpoints.userWalletDetails}$_userId";

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "accept": "application/json",
          "Authorization": "Bearer $_accessToken",
        },
      );

      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return CurrentUserWalletModel.fromJson(decoded);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // ---------------- Credit Wallet ----------------
  Future<CurrentUserWalletModel?> creditWallet(int amount) async {
    return _updateWallet(amount, "credit");
  }

  // ---------------- Debit Wallet ----------------
  Future<CurrentUserWalletModel?> debitWallet(int amount) async {
    return _updateWallet(amount, "debit");
  }

  // ---------------- Private Helper for Wallet Update ----------------
  Future<CurrentUserWalletModel?> _updateWallet(
      int amount, String transactionType) async {
    await _loadCredentials();

    if (_userId == null || _accessToken == null) {
      return null;
    }

    final url = Uri.parse(FastApiEndpoints.updateWallet(_userId!));

    try {
      final response = await http.put(
        url,
        headers: {
          "accept": "application/json",
          "Authorization": "Bearer $_accessToken",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "amount": amount,
          "transactionType": transactionType,
        }),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return CurrentUserWalletModel.fromJson(decoded);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }



  Future<bool> createSession({
    required String astrologerId,
    required String sessionType, // "Audio Call", "Video Call", or "Chat"
  }) async {
    await _loadCredentials(); // make sure _userId and _accessToken are loaded

    if (_userId == null || _accessToken == null) {
      print("❌ Missing credentials: userId=$_userId, accessToken=$_accessToken");
      return false;
    }

    final url = Uri.parse(FastApiEndpoints.createSession);

    final body = {
      "user_id": _userId,
      "astrologer_id": astrologerId,
      "session_type": sessionType,
    };

    print("🔹 API URL: $url");
    print("📦 Request Body: $body");

    try {
      final response = await http.post(
        url,
        headers: {
          "accept": "application/json",
          "Authorization": "Bearer $_accessToken",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      print("📤 Request sent to FastAPI");
      print("📥 Response Status Code: ${response.statusCode}");
      print("📄 Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Session created successfully!");
        return true;
      } else {
        print("❌ Failed to create session: ${response.body}");
        return false;
      }
    } catch (e) {
      print("⚠️ Error creating session: $e");
      return false;
    }
  }



}
