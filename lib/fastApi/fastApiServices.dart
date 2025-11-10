import 'dart:async';
import 'dart:convert';
import 'dart:io';
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
import '../model/fastApiModel/newChatModel.dart';
import '../model/fastApiModel/sendMoneyModel.dart';

extension MultipartFieldHelper on http.MultipartRequest {
  void addIfPresent(String key, String? value) {
    if (value != null && value.trim().isNotEmpty) {
      fields[key] = value.trim();
    }
  }
}

class FastAPIServices {
  String? _accessToken;
  String? _userId;

  String? get userId => _userId;
  String? get accessToken => _accessToken;

  /// 🗂️ Get Chat History (Refactored to use internal credentials)
  Future<List<ChatMessage>> getChatHistory(String otherUserId) async {
    await _loadCredentials();

    if (_accessToken == null) {
      debugPrint("❌ Token is null. Cannot fetch chat history.");
      throw Exception('Authentication required to fetch chat history.');
    }

    final url = Uri.parse(
      "https://fastapi.jyotishionline.com/chat/history/$otherUserId?page=1&size=20",
    );

    debugPrint("🌐 Fetching chat history for user: $otherUserId");
    debugPrint("🔗 API URL: $url");

    try {
      final response = await http.get(
        url,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
      );

      debugPrint("📦 Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['messages'] != null) {
          final messages = (data['messages'] as List)
              .map((msg) => ChatMessage.fromJson(msg))
              .toList();

          debugPrint("✅ Successfully fetched ${messages.length} messages.");
          return messages.reversed.toList(); // optional: newest last
        } else {
          debugPrint("⚠️ No 'messages' key found in response.");
          return [];
        }
      } else {
        debugPrint("❌ Failed to load chat history: ${response.body}");
        throw Exception('Failed to load chat history');
      }
    } catch (e, st) {
      debugPrint("💥 Exception while fetching chat history: $e");
      debugPrint("📄 Stack trace: $st");
      rethrow;
    }
  }



  /// Create customer detail (multipart/form-data)
  /// Does NOT send fcm_token (backend stores it separately).
  Future<CustomerDetail> createCustomerDetailFromPath({
    String? name,
    String? contactNo,
    String? birthDate,     // yyyy-MM-dd
    String? birthTime,     // HH:mm or "hh:mm a"
    String? birthPlace,
    String? addressLine1,
    String? addressLine2,
    String? location,      // "City,State,Country"
    int? pincode,
    String? gender,
    String? profile,       // optional bio/description
    String? token,         // optional (kept only if API accepts)
    String? expirationDate,
    String? countryCode,
    String? profilePicPath,
  }) async {
    await _loadCredentials(); // uses your existing loader
    if (_accessToken == null) {
      throw Exception("Not authenticated: missing access token");
    }

    final uri = Uri.parse(FastApiEndpoints.customerDetails);
    debugPrint("📤 [CUSTOMER DETAIL] → POST $uri");

    final req = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $_accessToken'
      ..headers['accept'] = 'application/json';

    // Only send fields that exist
    req.addIfPresent('name', name);
    req.addIfPresent('contactNo', contactNo);
    req.addIfPresent('birthDate', birthDate);
    req.addIfPresent('birthTime', birthTime);
    req.addIfPresent('birthPlace', birthPlace);
    req.addIfPresent('addressLine1', addressLine1);
    req.addIfPresent('addressLine2', addressLine2);
    req.addIfPresent('location', location);
    req.addIfPresent('gender', gender);
    req.addIfPresent('profile', profile);
    req.addIfPresent('token', token);
    req.addIfPresent('expirationDate', expirationDate);
    req.addIfPresent('countryCode', countryCode);
    if (pincode != null) req.fields['pincode'] = pincode.toString();

    // Optional file
    if (profilePicPath != null &&
        profilePicPath.isNotEmpty &&
        File(profilePicPath).existsSync()) {
      debugPrint("🖼️ [CUSTOMER DETAIL] attaching profile_pic: $profilePicPath");
      req.files.add(await http.MultipartFile.fromPath('profile_pic', profilePicPath));
    } else {
      debugPrint("🖼️ [CUSTOMER DETAIL] no profile_pic attached");
    }

    // Debug dump
    debugPrint("📝 [CUSTOMER DETAIL] fields: ${req.fields}");

    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    debugPrint("✅ [CUSTOMER DETAIL] status=${res.statusCode}");
    debugPrint("🧾 [CUSTOMER DETAIL] body=${res.body}");

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return CustomerDetail.fromJson(data);
    }
    throw Exception("Customer detail failed (${res.statusCode}): ${res.body}");
  }




  /// 🔹 Signup With Details (multipart/form-data)
  /// Creates User, CustomerDetail, and UserWallet in a single request.
  Future<Map<String, dynamic>?> signupWithDetails({
    required String name,
    required String contactNo,
    required String countryCode,
    required String email,
    required String password,
    required int pincode,
    String? birthDate,
    String? birthTime,
    String? birthPlace,
    String? addressLine1,
    String? addressLine2,
    String? location,
    String? gender,
    String? profile,
    String? fcmToken,
    String? token,
    String? profilePicPath, // optional local file path for image
  }) async {
    final url = Uri.parse(FastApiEndpoints.signupWithDetails);

    try {
      final request = http.MultipartRequest('POST', url)
        ..headers['accept'] = 'application/json';

      // ✅ Required fields
      request.fields['name'] = name;
      request.fields['contactNo'] = contactNo;
      request.fields['countryCode'] = countryCode;
      request.fields['email'] = email;
      request.fields['password'] = password;
      request.fields['pincode'] = pincode.toString();

      // ✅ Optional fields
      if (birthDate != null) request.fields['birthDate'] = birthDate;
      if (birthTime != null) request.fields['birthTime'] = birthTime;
      if (birthPlace != null) request.fields['birthPlace'] = birthPlace;
      if (addressLine1 != null) request.fields['addressLine1'] = addressLine1;
      if (addressLine2 != null) request.fields['addressLine2'] = addressLine2;
      if (location != null) request.fields['location'] = location;
      if (gender != null) request.fields['gender'] = gender;
      if (profile != null) request.fields['profile'] = profile;
      if (fcmToken != null) request.fields['fcm_token'] = fcmToken;
      if (token != null) request.fields['token'] = token;

      // ✅ Optional image upload
      if (profilePicPath != null && profilePicPath.isNotEmpty) {
        final file = File(profilePicPath);
        if (await file.exists()) {
          request.files.add(await http.MultipartFile.fromPath('profile_pic', profilePicPath));
          debugPrint("🖼️ Profile picture attached: $profilePicPath");
        } else {
          debugPrint("⚠️ Profile picture not found at path: $profilePicPath");
        }
      }

      debugPrint("🚀 Sending signup request → $url");
      debugPrint("🧾 Fields: ${request.fields}");

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint("📡 Response Status: ${response.statusCode}");
      debugPrint("📦 Response Body: ${response.body}");

      // ✅ Handle success
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // Automatically save credentials if token is returned
        if (data is Map && data.containsKey("access_token")) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("access_token", data["access_token"]);
          if (data["user"]?["id"] != null) {
            await prefs.setString("user_id", data["user"]["id"].toString());
          }
          debugPrint("🔐 Credentials saved locally after signup!");
        }

        debugPrint("✅ Signup Successful!");
        return data;
      } else {
        debugPrint("❌ Signup Failed (${response.statusCode}) → ${response.body}");
        try {
          final error = jsonDecode(response.body);
          return {"error": true, "message": error["detail"] ?? "Signup failed"};
        } catch (_) {
          return {"error": true, "message": "Unexpected error occurred"};
        }
      }
    } catch (e) {
      debugPrint("💥 Signup Exception: $e");
      return {"error": true, "message": e.toString()};
    }
  }








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

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString("access_token");
    _userId = prefs.getString("user_id");
    print("📦 Loaded from storage → userId=$_userId, token=$_accessToken");
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

    try {
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

        // 1️⃣ Access Token
        _accessToken = data["access_token"];

        // 2️⃣ Extract and set User ID safely
        final userJson = data["user"];
        if (userJson != null) {
          final user = UserModel.fromJson(userJson);
          _userId = user.id?.toString();
        }

        // 3️⃣ Save credentials locally
        final prefs = await SharedPreferences.getInstance();
        if (_accessToken != null) {
          await prefs.setString("access_token", _accessToken!);
        }
        if (_userId != null) {
          await prefs.setString("user_id", _userId!);
        }

        print("✅ Token and UserId saved successfully!");
      } else {
        print("🚨 Login failed with status: ${response.statusCode}");
        throw Exception("Login failed: ${response.body}");
      }
    } catch (e) {
      print("❌ Exception during login: $e");
      rethrow;
    }
  }


  // ---------------- SEND OTP ----------------
  Future<http.Response> sendOtp({
    required String contactNo,
    required String countryCode,
    bool sendWhatsapp = true,
    bool sendSms = true,
  }) async {
    final url = Uri.parse(FastApiEndpoints.sendMobileOtp);

    print("🌐 Sending OTP to $contactNo ($countryCode)");
    print("📦 send_whatsapp: $sendWhatsapp, send_sms: $sendSms");

    final response = await http.post(
      url,
      headers: {
        "accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: {
        "contactNo": contactNo,
        "countryCode": countryCode,
        "send_whatsapp": sendWhatsapp.toString(),
        "send_sms": sendSms.toString(),
      },
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

  Future<CustomerDetail> updateCustomerDetailFromPath({
    String? name,
    String? contactNo,
    String? birthDate,     // e.g. "2025-11-05"
    String? birthTime,     // e.g. "14:30"
    String? profile,
    String? birthPlace,
    String? addressLine1,
    String? addressLine2,
    String? location,
    int?    pincode,
    String? gender,
    String? fcmToken,      // API field name is fcm_token (mapped below)
    String? token,
    String? expirationDate, // ISO8601 if sending datetime
    String? countryCode,
    String? profilePicPath, // local file path for profile_pic
  }) async {
    await _loadCredentials();
    if (_accessToken == null) {
      throw Exception("Not authenticated: missing access token");
    }

    final uri = Uri.parse(FastApiEndpoints.customerDetails);
    debugPrint("🩹 [CUSTOMER DETAIL] → PATCH $uri");

    final req = http.MultipartRequest('PATCH', uri)
      ..headers['Authorization'] = 'Bearer $_accessToken'
      ..headers['accept'] = 'application/json';

    // Add only present fields (helper defined at top of your file)
    req.addIfPresent('name', name);
    req.addIfPresent('contactNo', contactNo);
    req.addIfPresent('birthDate', birthDate);
    req.addIfPresent('birthTime', birthTime);
    req.addIfPresent('profile', profile);
    req.addIfPresent('birthPlace', birthPlace);
    req.addIfPresent('addressLine1', addressLine1);
    req.addIfPresent('addressLine2', addressLine2);
    req.addIfPresent('location', location);
    if (pincode != null) req.fields['pincode'] = pincode.toString();
    req.addIfPresent('gender', gender);
    // API expects fcm_token in snake_case
    req.addIfPresent('fcm_token', fcmToken);
    req.addIfPresent('token', token);
    req.addIfPresent('expirationDate', expirationDate);
    req.addIfPresent('countryCode', countryCode);

    // Optional file
    if (profilePicPath != null && profilePicPath.isNotEmpty) {
      final file = File(profilePicPath);
      if (await file.exists()) {
        debugPrint("🖼️ [CUSTOMER DETAIL] attaching profile_pic: $profilePicPath");
        req.files.add(await http.MultipartFile.fromPath('profile_pic', profilePicPath));
      } else {
        throw Exception("profilePicPath not found: $profilePicPath");
      }
    } else {
      debugPrint("🖼️ [CUSTOMER DETAIL] no profile_pic attached");
    }

    // Debug
    debugPrint("📝 [CUSTOMER DETAIL] fields: ${req.fields.keys.toList()}");

    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);

    debugPrint("✅ [CUSTOMER DETAIL PATCH] status=${res.statusCode}");
    debugPrint("🧾 [CUSTOMER DETAIL PATCH] body=${res.body}");

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final Map<String, dynamic> data = jsonDecode(res.body);
      return CustomerDetail.fromJson(data);
    }

    // Surface validation / backend errors verbosely
    throw Exception("Update failed (${res.statusCode}): ${res.body}");
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



  /// 🗂️ Get Chat History (Refactored to use internal credentials)
  /// 🗂️ Get Chat History (Using `other_user_id` as required by API)
  Future<List<dynamic>> fetchChatHistory(String otherUserId) async {
    // 1. Ensure internal credentials (_accessToken and _userId) are loaded and valid
    await _loadCredentials();

    if (_accessToken == null) {
      debugPrint("❌ Token is null. Cannot fetch chat history.");
      throw Exception('Authentication required to fetch chat history.');
    }

    // ✅ Correct API endpoint as per your documentation
    final url = Uri.parse(
      "https://fastapi.jyotishionline.com/chat/history/$otherUserId?page=1&size=20",
    );

    debugPrint("🌐 Fetching chat history for user: $otherUserId");
    debugPrint("🔗 API URL: $url");

    try {
      final response = await http.get(
        url,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $_accessToken', // ✅ internal token
        },
      );

      debugPrint("📦 Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check for valid message list
        if (data['messages'] != null) {
          debugPrint("✅ Chat history fetched successfully. Total messages: ${data['messages'].length}");
          return List.from(data['messages'].reversed); // reverse for correct order
        } else {
          debugPrint("⚠️ No messages found in response.");
          return [];
        }
      } else {
        debugPrint("❌ Failed to load chat history. Response: ${response.body}");
        throw Exception('Failed to load chat history: Status ${response.statusCode}');
      }
    } catch (e, st) {
      debugPrint("💥 Exception while fetching chat history: $e");
      debugPrint("📄 Stack trace: $st");
      rethrow;
    }


  }

  /// 🕒 Get Last Message in a Chat Room
  Future<Map<String, dynamic>> getLastMessage(String roomId) async {
    final url = Uri.parse(FastApiEndpoints.getLastMessage(roomId));
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('❌ Failed to load last message: ${response.body}');
    }
  }

  /// ✅ Mark Messages as Read
  Future<bool> markAsRead(String roomId) async {
    final url = Uri.parse(FastApiEndpoints.markMessagesAsRead(roomId));
    final response = await http.post(url);

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('❌ Failed to mark messages as read: ${response.body}');
    }
  }

  /// ✉️ Send a Chat Message
  Future<Map<String, dynamic>> sendMessage({
    required String roomId,
    required String senderId,
    required String receiverId,
    required String message,
  }) async {
    final url = Uri.parse(FastApiEndpoints.sendMessage  );

    final body = {
      "room_id": roomId,
      "sender_id": senderId,
      "receiver_id": receiverId,
      "message": message,
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('❌ Failed to send message: ${response.body}');
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




  Future<Map<String, dynamic>?> createSession({
    required String astrologerId,
    required String sessionType, // "chat" | "audio_call" | "video_call"
  }) async {
    await _loadCredentials(); // make sure _userId and _accessToken are loaded

    if (_userId == null || _accessToken == null) {
      print("❌ Missing credentials: userId=$_userId, accessToken=$_accessToken");
      return null;
    }

    final url = Uri.parse(FastApiEndpoints.createSession);

    final body = {
      "user_id": _userId,           // if your backend derives user from token, you can omit this
      "astrologer_id": astrologerId,
      "session_type": sessionType,  // e.g. "chat", "audio_call", "video_call"
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
        final decoded = jsonDecode(response.body);

        // Your API returns a flat object:
        // {"room_id": "...", "id": 174, "user_id": "...", "astrologer_id": "...", ...}
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }

        // If server ever wraps it: { "data": { ... } }
        if (decoded is Map && decoded['data'] is Map<String, dynamic>) {
          return decoded['data'] as Map<String, dynamic>;
        }

        print("⚠️ Unexpected JSON shape for createSession");
        return null;
      } else {
        print("❌ Failed to create session: ${response.body}");
        return null;
      }
    } catch (e) {
      print("⚠️ Error creating session: $e");
      return null;
    }
  }
  Future<SendMoneyResponse> sendMoney({
    required String astrologerId,
    required num amount,
    String type = 'send_money',
  }) async {
    // Load creds (sets _userId and _accessToken)
    await _loadCredentials();

    // 🔍 Debug credentials
    debugPrint("💸 [sendMoney] ▶ start");
    debugPrint("💸 [sendMoney] userId=$_userId  tokenPresent=${_accessToken != null}");
    debugPrint("💸 [sendMoney] astrologerId=$astrologerId  amount=$amount  type=$type");

    if (_userId == null || _userId!.isEmpty) {
      throw Exception('Not authenticated: missing user id');
    }
    if (_accessToken == null || _accessToken!.isEmpty) {
      throw Exception('Not authenticated: missing access token');
    }

    final uri = Uri.parse(FastApiEndpoints.sendMoney);
    final headers = <String, String>{
      'accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_accessToken',
    };
    final body = <String, dynamic>{
      'user_id': _userId,            // ✅ from storage
      'astrologer_id': astrologerId, // ✅ from caller
      'amount': amount,
      'type': type,
    };

    // 🔎 Log request
    debugPrint("💸 [sendMoney] URL: $uri");
    debugPrint("💸 [sendMoney] HEADERS: ${jsonEncode(headers)}");
    debugPrint("💸 [sendMoney] BODY: ${jsonEncode(body)}");

    final response = await http.post(uri, headers: headers, body: jsonEncode(body));

    // 📦 Log response
    debugPrint("💸 [sendMoney] STATUS: ${response.statusCode}");
    debugPrint("💸 [sendMoney] RESP: ${response.body}");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonMap = (response.body.isNotEmpty)
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{'message': 'Money sent successfully'};
      final parsed = SendMoneyResponse.fromJson(jsonMap);

      debugPrint("✅ [sendMoney] OK → txId=${parsed.transactionId} type=${parsed.transactionType} "
          "userBal=${parsed.userBalance} astroBal=${parsed.astroBalance}");
      return parsed;
    } else {
      String details = response.body;
      try {
        final j = jsonDecode(response.body);
        if (j is Map && j['detail'] != null) details = j['detail'].toString();
      } catch (_) {}
      debugPrint("💥 [sendMoney] ERROR ${response.statusCode}: $details");
      throw Exception('Send money failed (${response.statusCode}): $details');
    }



  Future<Map<String, dynamic>> getAgoraVideoTokenForCustomer({
    required String astroId,
  }) async {
    // Load credentials from storage into _accessToken / _userId
    await _loadCredentials();
    if (_accessToken == null || _accessToken!.isEmpty) {
      throw Exception("No bearer token. Please log in again.");
    }

    final url = Uri.parse("https://fastapi.jyotishionline.com/agora/token/video")
        .replace(queryParameters: {"astro_id": astroId});

    debugPrint("🎥 [AGORA] Requesting token for astro_id=$astroId");
    debugPrint("🔗 URL: $url");

    final resp = await http.get(
      url,
      headers: {
        "accept": "application/json",
        "Authorization": "Bearer $_accessToken", // ✅ use the customer token
      },
    );

    debugPrint("🎥 [AGORA] status=${resp.statusCode}");
    debugPrint("🎥 [AGORA] body=${resp.body}");

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      // sanity log
      debugPrint("✅ Got channel=${data['channelName']} appID=${data['appID']}");
      return data;
    } else {
      throw Exception("Failed: ${resp.statusCode} ${resp.body}");
    }
  }











}}
