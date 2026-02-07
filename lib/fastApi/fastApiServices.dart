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
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:AstrowayCustomer/utils/global.dart' as global;
import 'package:shared_preferences/shared_preferences.dart';

import '../model/fastApiModel/LiveAstrologerModel.dart';
import '../model/fastApiModel/NotificationModel.dart';
import '../model/fastApiModel/OnlineAstrologerModel.dart';
import '../model/fastApiModel/allAstrologerModel.dart';
import '../model/fastApiModel/astrologerProfileModel.dart';
import '../model/fastApiModel/newChatModel.dart';
import '../model/fastApiModel/sendMoneyModel.dart';
import '../model/fastApiModel/wallet_tx_model.dart';

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


  Future<bool> ensureAuthenticated() async {
    await _loadCredentials();
    return _accessToken != null &&
        _accessToken!.isNotEmpty &&
        _userId != null &&
        _userId!.isNotEmpty;
  }


  Future<List<dynamic>> getCosmicServices() async {
    try {
      final response = await http.get(
        Uri.parse(FastApiEndpoints.cosmicServices),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body["services"] ?? [];
      } else {
        print("❌ API Error: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ getCosmicServices Error: $e");
      return [];
    }
  }

  // ---------------- SEND OTP (NEW CUSTOMER API) ----------------
  Future<bool> sendCustomerOtp({
    required String contactNo,
    required String countryCode,
    required String username,
    required String email,
  }) async {
    final Uri url = Uri.parse(
      "${FastApiEndpoints.fastApiBaseUrl}/api/v1/customer/send-otp",
    );

    debugPrint("📲 [SEND CUSTOMER OTP]");
    debugPrint("📞 contact_no=$contactNo");
    debugPrint("🌍 country_code=$countryCode");
    debugPrint("👤 username=$username");
    debugPrint("📧 email=$email");
    debugPrint("🔗 URL=$url");

    try {
      final response = await http.post(
        url,
        headers: {
          "accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "contact_no": contactNo,
          "country_code": countryCode,
          "username": username,
          "email": email,
        },
      );

      debugPrint("📡 Status: ${response.statusCode}");
      debugPrint("📩 Body  : ${response.body}");

      if (response.statusCode == 200) {
        return true;
      }

      // Try to parse error message from response
      final responseBody = response.body;

      // Check if response is JSON
      try {
        final jsonResponse = json.decode(responseBody);
        if (jsonResponse.containsKey('detail')) {
          // If it's a FastAPI error with 'detail' field
          throw Exception(jsonResponse['detail'].toString());
        } else if (jsonResponse.containsKey('message')) {
          // If it has a 'message' field
          throw Exception(jsonResponse['message'].toString());
        } else if (jsonResponse.containsKey('error')) {
          // If it has an 'error' field
          throw Exception(jsonResponse['error'].toString());
        }
      } catch (e) {
        // If parsing fails, throw raw response
      }

      // Throw raw response body if not JSON or no specific field found
      throw Exception(responseBody);

    } on http.ClientException catch (e) {
      // Network or connection error
      debugPrint("🌐 Network Error: $e");
      throw Exception("Network error: ${e.message}");
    } on FormatException catch (e) {
      // Response format error
      debugPrint("📄 Format Error: $e");
      throw Exception("Invalid response format");
    } on TimeoutException catch (e) {
      // Request timeout
      debugPrint("⏰ Timeout Error: $e");
      throw Exception("Request timeout");
    } catch (e) {
      // Any other error
      debugPrint("❌ Unexpected Error: $e");
      rethrow;
    }
  }




  /// 🎟️ Apply Coupon (FREE SERVICE)
  Future<bool> applyCoupon({
    required String couponCode,
  }) async {
    await _loadCredentials();

    if (_userId == null || _accessToken == null) {
      return false;
    }

    final url = Uri.parse("${FastApiEndpoints.userReviews}");

    final body = {
      "user_id": _userId,
      "coupon_code": couponCode,
    };


    try {
      final response = await http.post(
        url,
        headers: {
          "accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $_accessToken",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // ✅ THIS IS THE ONLY CHECK WE NEED
        return data["status"] == "success";
      }

      return false;
    } catch (e) {
      print("❌ applyCoupon error: $e");
      return false;
    }
  }

  /// ⭐ Submit User Review
  Future<bool> submitUserReview({
    required String astrologerId,
    required int rating,
    required String review,
    bool isPublic = true,
  }) async {
    await _loadCredentials();

    if (_userId == null || _accessToken == null) {
      debugPrint("❌ UserId or token missing");
      return false;
    }

    final url = Uri.parse(
      "${FastApiEndpoints.fastApiBaseUrl}/api/v1/userreviews",
    );

    final body = {
      "userId": _userId,
      "astrologerId": astrologerId,
      "rating": rating,
      "review": review,
      "reply": "",              // ✅ REQUIRED
      "isActive": true,
      "isDelete": false,        // ✅ REQUIRED
      "isPublic": isPublic,
      "createdBy": 0,           // ✅ REQUIRED
      "modifiedBy": 0,          // ✅ REQUIRED
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $_accessToken",
        },
        body: jsonEncode(body),
      );

      debugPrint("⭐ Review Status: ${response.statusCode}");
      debugPrint("⭐ Review Body: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("❌ submitUserReview error: $e");
      return false;
    }
  }









  Future<List<ChatMessage>> getChatHistory(
      String otherUserId, {
        int page = 1,
        int size = 20,
      }) async {
    await _loadCredentials();

    if (_accessToken == null) {
      debugPrint("❌ Token is null. Cannot fetch chat history.");
      throw Exception('Authentication required to fetch chat history.');
    }

    final url = Uri.parse(
      "https://fastapi.jyotishionline.com/chat/history/$otherUserId"
          "?page=$page&size=$size",
    );

    debugPrint("🌐 Fetching chat history");
    debugPrint("👤 Other User: $otherUserId");
    debugPrint("📄 Page: $page | Size: $size");
    debugPrint("🔗 URL: $url");

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

          debugPrint("✅ Fetched ${messages.length} messages");
          return messages; // ❗ DO NOT reverse here
        } else {
          debugPrint("⚠️ 'messages' key missing");
          return [];
        }
      } else {
        debugPrint("❌ Failed: ${response.body}");
        throw Exception('Failed to load chat history');
      }
    } catch (e, st) {
      debugPrint("💥 Exception: $e");
      debugPrint("📄 StackTrace: $st");
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

  /// 🔔 Register FCM token for logged-in customer
  Future<void> registerCustomerFcmToken(String userId) async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      print("📲 Current FCM Token → $fcmToken");

      if (fcmToken == null || fcmToken.isEmpty) {
        print("⚠️ No FCM token available, skipping registration.");
        return;
      }

      final url = Uri.parse(FastApiEndpoints.registerCustomerFcmToken);

      final body = jsonEncode({
        "user_id": userId,
        "fcm_token": fcmToken,
      });

      print("🚀 Registering FCM token for user: $userId");
      print("🌐 URL: $url");
      print("📦 Body: $body");

      final response = await http.post(
        url,
        headers: {
          "accept": "application/json",
          "Content-Type": "application/json",
        },
        body: body,
      );

      print("📡 FCM Register Status: ${response.statusCode}");
      print("📩 FCM Register Response: ${response.body}");
    } catch (e) {
      print("❌ Error while registering FCM token: $e");
    }
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
    String? profilePicPath,
  }) async {
    final url = Uri.parse(FastApiEndpoints.signupWithDetails);

    try {
      final request = http.MultipartRequest('POST', url)
        ..headers['accept'] = 'application/json';

      // ✅ REQUIRED (snake_case)
      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['password'] = password;
      request.fields['contact_no'] = contactNo;
      request.fields['country_code'] = countryCode;
      request.fields['pincode'] = pincode.toString();

      // ✅ OPTIONAL
      if (birthDate != null) request.fields['birth_date'] = birthDate;
      if (birthTime != null) request.fields['birth_time'] = birthTime;
      if (birthPlace != null) request.fields['birth_place'] = birthPlace;
      if (addressLine1 != null) request.fields['address_line1'] = addressLine1;
      if (addressLine2 != null) request.fields['address_line2'] = addressLine2;
      if (location != null) request.fields['location'] = location;
      if (gender != null) request.fields['gender'] = gender;
      if (profile != null) request.fields['profile'] = profile;
      if (fcmToken != null) request.fields['fcm_token'] = fcmToken;

      // ✅ IMAGE (ONLY IF EXISTS)
      if (profilePicPath != null && profilePicPath.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profile_pic',
            profilePicPath,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        return {
          "error": true,
          "message": error["detail"]?.toString() ?? "Signup failed",
        };
      }
    } catch (e) {
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
  Future<bool> hasValidSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");
    final userId = prefs.getString("user_id");

    print("🔐 [SESSION CHECK] token=$token userId=$userId");

    return token != null && token.isNotEmpty && userId != null;
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

  /// ✅ PATCH /api/v1/customerdetails/{user_id}
  /// Multipart update for customer detail with optional profile_pic.
  /// ✅ PATCH /api/v1/customerdetails/{user_id}
  Future<CustomerDetail> patchCustomerDetailByUserId({
    required String userId,

    String? name,
    String? contactNo,
    String? email,
    String? birthDate,        // yyyy-MM-dd
    String? birthTime,        // HH:mm
    String? profile,
    String? birthPlace,
    String? addressLine1,
    String? addressLine2,
    String? location,
    int?    pincode,
    String? gender,
    String? fcmToken,
    String? countryCode,

    /// local file path
    String? profilePicPath,
  }) async {
    await _loadCredentials();

    if (_accessToken == null || _accessToken!.isEmpty) {
      throw Exception("❌ Missing access token");
    }

    final base = FastApiEndpoints.customerDetails.replaceAll(RegExp(r'/+$'), '');
    final uri  = Uri.parse("$base/$userId");

    debugPrint("────────────────────────────────────────");
    debugPrint("🩹 PATCH CUSTOMER DETAIL");
    debugPrint("🆔 User ID : $userId");
    debugPrint("🌐 URL     : $uri");
    debugPrint("────────────────────────────────────────");

    final req = http.MultipartRequest("PATCH", uri)
      ..headers.addAll({
        "accept": "application/json",
        "Authorization": "Bearer $_accessToken",
      });

    /// helper → add only valid fields
    void add(String key, dynamic value) {
      if (value != null && value.toString().trim().isNotEmpty) {
        req.fields[key] = value.toString().trim();
      }
    }

    /// ✅ EXACT API FIELD NAMES (snake_case)
    add("name", name);
    add("contact_no", contactNo);
    add("email", email);
    add("birth_date", birthDate);
    add("birth_time", birthTime);
    add("profile", profile);
    add("birth_place", birthPlace);
    add("address_line1", addressLine1); // 🔥 FIX
    add("address_line2", addressLine2); // 🔥 FIX
    add("location", location);
    if (pincode != null) add("pincode", pincode);
    add("gender", gender);
    add("fcm_token", fcmToken);
    add("country_code", countryCode);

    /// 📸 Profile Image
    if (profilePicPath != null && profilePicPath.isNotEmpty) {
      final file = File(profilePicPath);
      if (await file.exists()) {
        debugPrint("🖼 Attaching profile_pic: $profilePicPath");
        req.files.add(
          await http.MultipartFile.fromPath("profile_pic", profilePicPath),
        );
      } else {
        debugPrint("⚠ profilePicPath does not exist: $profilePicPath");
      }
    } else {
      debugPrint("🖼 No profile_pic provided");
    }

    debugPrint("📝 Fields Sent → ${req.fields}");

    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);

    debugPrint("📡 PATCH Status : ${res.statusCode}");
    debugPrint("📩 PATCH Body   : ${res.body}");

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return CustomerDetail.fromJson(jsonDecode(res.body));
    }

    throw Exception("❌ Update failed (${res.statusCode}): ${res.body}");
  }







  // A method to fetch wallet transactions
  // ---------------- FETCH WALLET TRANSACTIONS ----------------
  Future<List<WalletTxModel>> getWalletTransactions() async {
    await _loadCredentials();

    // ✅ JWT is mandatory for authorization
    if (_accessToken == null || _accessToken!.isEmpty) {
      throw Exception('Access token missing. Please login again.');
    }

    // ✅ Ensure we have the userId to build the path
    if (_userId == null || _userId!.isEmpty) {
      throw Exception('User ID missing. Cannot fetch transactions.');
    }

    // ✅ HARDCODED WORKING URL STRUCTURE
    // Path corrected from 'wallettransactions' to 'wallet/transactions'
    // Added '/user/$_userId' to the end of the URL
    final String baseUrl = "https://fastapi.jyotishionline.com/api/v1";
    final url = Uri.parse('$baseUrl/wallet/transactions/user/$_userId');

    debugPrint("💰 Wallet Tx API → $url");
    debugPrint("🔑 Using JWT and Path ID for user identification");

    try {
      final response = await http.get(
        url,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $_accessToken', // Keep the token for security
        },
      );

      debugPrint("💰 Wallet Tx Status → ${response.statusCode}");
      debugPrint("💰 Wallet Tx Body → ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(response.body);

        return decoded
            .map((e) => WalletTxModel.fromJson(e))
            .toList();
      }

      if (response.statusCode == 401) {
        throw Exception("Unauthorized. Token may be expired.");
      }

      if (response.statusCode == 404) {
        throw Exception("Wallet transactions not found (404). Check if the URL path is correct.");
      }

      throw Exception(
        "Failed to load wallet transactions (${response.statusCode})",
      );
    } catch (e, st) {
      debugPrint("❌ Wallet Tx Exception: $e");
      debugPrint("📄 StackTrace: $st");
      rethrow;
    }
  }




  // ---------------- LOGIN WITH EMAIL ----------------
  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse(FastApiEndpoints.login); // → /api/v1/auth/login

      print("🔗 Login URL → $url");

      final response = await http.post(
        url,
        headers: {
          "accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          // ⚠️ MUST be 'username' as per /auth/login, NOT 'email'
          "username": email,
          "password": password,
        },
      );

      print("🔍 Status Code: ${response.statusCode}");
      print("📩 Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final accessToken = data["access_token"];
        final userJson = data["user"];

        final user = UserModel.fromJson(userJson);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("access_token", accessToken);
        await prefs.setString("user_id", user.id);
        await prefs.setString("user_name", user.name);

        print("✅ Login success for user: ${user.id}");
        print("🔐 Stored access_token (length): ${accessToken.length}");

        // 🔔 Register FCM token for this logged-in user
        await registerCustomerFcmToken(user.id);

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
        final details = jsonDecode(response.body)["detail"];
        final errorMessage = details is List && details.isNotEmpty
            ? details.first["msg"]
            : "Invalid email or password";

        Get.snackbar(
          "Error",
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "Error",
          "Login failed. Please check your credentials.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("❌ Network error: $e");
      Get.snackbar(
        "Error",
        "Failed to connect to the server.",
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
  Future<List<GetAllAstrologerModel>> fetchAllAstrologers({
    int page = 1,
    int size = 10,
  }) async {
    await _loadCredentials();

    final url = Uri.parse(
      "${FastApiEndpoints.allAstrologers}?page=$page&size=$size",
    );

    print("🔮 [API CALL] Fetching astrologers from $url");

    final response = await http.get(
      url,
      headers: {
        "accept": "application/json",
        if (_accessToken != null)
          "Authorization": "Bearer $_accessToken",
      },
    );

    print("📡 Status Code: ${response.statusCode}");

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      /// ✅ PAGINATED LIST
      final List<dynamic> list = decoded['data'] ?? [];

      final astrologers = list
          .map((e) => GetAllAstrologerModel.fromJson(e))
          .toList();

      print("🧙‍♂️ Total Astrologers Fetched: ${astrologers.length}");

      return astrologers;
    } else if (response.statusCode == 401) {
      throw Exception("🚨 Unauthorized. Please login again.");
    } else {
      throw Exception("❌ Failed to fetch astrologers: ${response.body}");
    }
  }

  // ---------------- LOGOUT ----------------
  Future<void> logout() async {
    try {
      // 🔥 Delete FCM token
      await FirebaseMessaging.instance.deleteToken();
      print("🧨 FCM token deleted");

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove("access_token");
      await prefs.remove("user_id");
      await prefs.remove("customer_details");
      await prefs.remove("isLoggedIn");

      _accessToken = null;
      _userId = null;

      print("✅ User logged out successfully.");

      Get.offAll(() => LoginScreen());
    } catch (e) {
      print("❌ Failed to log out: $e");
    }
  }


  // ---------------- SEND OTP ----------------
  // ---------------- SEND OTP (CUSTOMER) ----------------
  Future<http.Response> sendOtp({
    required String contactNo,
    required String countryCode,
  }) async {
    final Uri url = Uri.parse(
      "https://fastapi.jyotishionline.com/api/v1/auth/send-otp",

    );

    debugPrint("────────────────────────────────────────");
    debugPrint("📲 [LOGIN SEND OTP]");
    debugPrint("📞 contactNo    : $contactNo");
    debugPrint("🌍 countryCode : $countryCode");
    debugPrint("🔗 URL         : $url");
    debugPrint("────────────────────────────────────────");

    final response = await http.post(
      url,
      headers: {
        "accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: {
        "contactNo": contactNo,
        "countryCode": countryCode.replaceAll("+", ""), // VERY IMPORTANT
        "send_whatsapp": "true",
        "send_sms": "true",
      },
    );

    debugPrint("📡 Status Code : ${response.statusCode}");
    debugPrint("📩 Response   : ${response.body}");

    return response;
  }




  // ---------------- VERIFY OTP ----------------
  // ---------------- VERIFY LOGIN OTP (CUSTOMER) ----------------
  Future<http.Response> verifyLoginOtp({
    required String contactNo,
    required String countryCode,
    required String otp,
  }) async {
    final url = Uri.parse(FastApiEndpoints.verifyLoginOtp);

    debugPrint("🔐 [VERIFY LOGIN OTP]");
    debugPrint("📞 contactNo   : $contactNo");
    debugPrint("🌍 countryCode: $countryCode");
    debugPrint("🔢 otp        : $otp");
    debugPrint("🔗 URL        : $url");

    final response = await http.post(
      url,
      headers: {
        "accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: {
        "contactNo": contactNo,
        "countryCode": countryCode,
        "otp": otp,
      },
    );

    debugPrint("📡 OTP VERIFY STATUS → ${response.statusCode}");
    debugPrint("📩 OTP VERIFY BODY   → ${response.body}");

    // --------------------------------------------------
    // ✅ HANDLE SUCCESS + SAVE SESSION + FCM
    // --------------------------------------------------
    if (response.statusCode == 200) {
      try {
        final decoded = jsonDecode(response.body);
        final loginResponse = LoginResponse.fromJson(decoded);

        final prefs = await SharedPreferences.getInstance();

        _accessToken = loginResponse.accessToken;
        _userId = loginResponse.user?.id;

        if (_accessToken != null && _accessToken!.isNotEmpty) {
          await prefs.setString("access_token", _accessToken!);
          debugPrint("🔐 Access token saved");
        } else {
          debugPrint("⚠️ Access token missing in response");
        }

        if (_userId != null && _userId!.isNotEmpty) {
          await prefs.setString("user_id", _userId!);
          debugPrint("👤 User ID saved → $_userId");
        } else {
          debugPrint("⚠️ User ID missing in response");
        }

        await prefs.setBool("isLoggedIn", true);
        debugPrint("✅ Login flag saved");

        // --------------------------------------------------
        // 🔔 FCM TOKEN REGISTRATION
        // --------------------------------------------------
        try {
          debugPrint("📲 Fetching FCM token...");
          final fcmToken = await FirebaseMessaging.instance.getToken();

          debugPrint("📲 FCM Token → $fcmToken");

          if (fcmToken != null && fcmToken.isNotEmpty && _userId != null) {
            debugPrint("🚀 Registering FCM token with backend...");
            await registerCustomerFcmToken(_userId!);
            debugPrint("✅ FCM token registered successfully");
          } else {
            debugPrint("⚠️ FCM token NULL / EMPTY or userId missing");
          }
        } catch (e) {
          debugPrint("❌ FCM registration failed: $e");
        }
        // --------------------------------------------------

      } catch (e, st) {
        debugPrint("❌ OTP post-login processing failed: $e");
        debugPrint("📄 StackTrace: $st");
      }
    }

    return response;
  }












  // ---------------- VERIFY SIGN IN OTP (CUSTOMER) ----------------
  Future<http.Response> verifyOtp({
    required String contactNo,
    required String countryCode,
    required String otp,
  }) async {
    final Uri url = Uri.parse(FastApiEndpoints.customerVerifyOtp);

    // 🧪 Debug logs (INPUT)
    debugPrint("────────────────────────────────────────");
    debugPrint("🔐 [VERIFY OTP]");
    debugPrint("📞 Contact No : $contactNo");
    debugPrint("🌍 Country   : $countryCode");
    debugPrint("🔢 OTP       : $otp");
    debugPrint("🔗 URL       : $url");
    debugPrint("────────────────────────────────────────");

    final payload = {
      "contactNo": contactNo,
      "countryCode": countryCode,
      "otp": otp,
    };

    global.showLoader();

    final response = await http.post(
      url,
      headers: {
        "accept": "application/json",
        "Content-Type": "application/json", // ✅ IMPORTANT
      },
      body: jsonEncode(payload), // ✅ JSON BODY
    );

    global.hideLoader();

    // 📡 Debug logs (RESPONSE)
    debugPrint("📡 [VERIFY OTP] Status Code : ${response.statusCode}");
    debugPrint("📩 [VERIFY OTP] Response   : ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final loginResponse = LoginResponse.fromJson(jsonData);

      final prefs = await SharedPreferences.getInstance();

      // 🔐 Save token
      _accessToken = loginResponse.accessToken;
      if (_accessToken != null && _accessToken!.isNotEmpty) {
        await prefs.setString("access_token", _accessToken!);
      }

      // 👤 Save user id
      _userId = loginResponse.user?.id;
      if (_userId != null && _userId!.isNotEmpty) {
        await prefs.setString("user_id", _userId!);
      } else {
        debugPrint("⚠️ [VERIFY OTP] User ID missing in response");
      }

      // 🗂 Save minimal customer info
      await prefs.setString(
        "customer_details",
        jsonEncode({
          "id": loginResponse.user.id,
          "contactNo": loginResponse.user.contactNo,
          "role": loginResponse.user.role,
        }),
      );

      await prefs.setBool("isLoggedIn", true);

      debugPrint("💾 [VERIFY OTP] Saved session → userId=$_userId");

      final bottomNavController = Get.find<BottomNavigationController>();
      bottomNavController.setBottomIndex(0, 0);
      Get.offAll(() => BottomNavigationBarScreen(index: 0));
    } else {
      String errorMessage = "Invalid OTP";

      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded["detail"] != null) {
          errorMessage = decoded["detail"].toString();
        }
      } catch (_) {}

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



  // ---------------- VERIFY OTP (NEW CUSTOMER API) ----------------
  Future<void> verifyCustomerOtp({
    required String contactNo,
    required String otp,
  }) async {
    final Uri url = Uri.parse(
      "${FastApiEndpoints.fastApiBaseUrl}/api/v1/customer/verify-otp",
    );

    debugPrint("🔐 [VERIFY CUSTOMER OTP]");
    debugPrint("📞 contact_no=$contactNo");
    debugPrint("🔢 otp=$otp");
    debugPrint("🔗 URL=$url");

    final response = await http.post(
      url,
      headers: {
        "accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: {
        "contact_no": contactNo,
        "otp": otp,
      },
    );

    debugPrint("📡 Status: ${response.statusCode}");
    debugPrint("📩 Body  : ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final loginResponse = LoginResponse.fromJson(data);

      final prefs = await SharedPreferences.getInstance();

      _accessToken = loginResponse.accessToken;
      _userId = loginResponse.user?.id;

      if (_accessToken != null) {
        await prefs.setString("access_token", _accessToken!);
        debugPrint("🔐 Access token saved");
      }

      if (_userId != null) {
        await prefs.setString("user_id", _userId!);
        debugPrint("👤 User ID saved → $_userId");
      }

      await prefs.setBool("isLoggedIn", true);
      debugPrint("✅ Login flag saved");

      // --------------------------------------------------
      // 🔔 FCM TOKEN REGISTRATION (🔥 THIS WAS MISSING)
      // --------------------------------------------------
      try {
        debugPrint("📲 Fetching FCM token...");
        final fcmToken = await FirebaseMessaging.instance.getToken();

        debugPrint("📲 FCM Token received → $fcmToken");

        if (fcmToken != null && fcmToken.isNotEmpty && _userId != null) {
          debugPrint("🚀 Registering FCM token with backend...");
          await registerCustomerFcmToken(_userId!);
          debugPrint("✅ FCM token registered successfully");
        } else {
          debugPrint("⚠️ FCM token is NULL or EMPTY");
        }
      } catch (e) {
        debugPrint("❌ FCM registration failed: $e");
      }
      // --------------------------------------------------

      debugPrint("🎉 OTP verified completely → navigating user");

      final bottomNavController = Get.find<BottomNavigationController>();
      bottomNavController.setBottomIndex(0, 0);

      Get.offAll(() => LoginScreen());
      return;
    }

    if (response.statusCode == 422) {
      final decoded = jsonDecode(response.body);
      throw Exception(decoded["detail"]?.toString() ?? "Invalid OTP");
    }

    throw Exception("Verify OTP failed (${response.statusCode})");
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
    _accessToken = prefs.getString("access_token");
    _userId = prefs.getString("user_id");
    print("🔑 _loadCredentials() → userId=$_userId, accessToken=$_accessToken");
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

  // ----------------------------------------------------------
// 🚀 Send Notification to Astrologer
// ----------------------------------------------------------
  Future<Map<String, dynamic>> sendNotificationToAstrologer({
    required String astrologerId,
    required String title,
    required String body,
    required String screen,
    Map<String, dynamic>? data,
  }) async {
    try {
      final url = Uri.parse(
          "${FastApiEndpoints.sendAstrologerNotification}");

      final payload = {
        "astrologer_id": astrologerId,
        "title": title,
        "body": body,
        "screen": screen,
        "data": data ?? {},
      };

      print("📡 Sending notification to astrologer...");
      print("🔗 URL: $url");
      print("🧾 Body: ${jsonEncode(payload)}");

      final response = await http.post(
        url,
        headers: {
          "accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode(payload),
      );

      print("⬅️ Response Status: ${response.statusCode}");
      print("⬅️ Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final res = jsonDecode(response.body);
        print("✅ Notification sent successfully!");
        print("   🔹 FCM Message ID: ${res['fcm_message_id'] ?? 'N/A'}");
        print("   🔹 Notification ID: ${res['notification_id'] ?? 'N/A'}");
        return {"success": true, "data": res};
      } else {
        print("❌ Failed to send notification: ${response.body}");
        return {
          "success": false,
          "error": "HTTP ${response.statusCode}: ${response.body}"
        };
      }
    } catch (e, stackTrace) {
      print("🔥 Exception while sending notification: $e");
      print(stackTrace);
      return {"success": false, "error": e.toString()};
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



  /// 🔴 Fetch All Live Astrologers (Agora Live List)
  Future<List<LiveAstrologerModel>> fetchLiveAstrologers() async {
    await _loadCredentials(); // Load token if required

    final url = Uri.parse("https://fastapi.jyotishionline.com/agora/live/list");

    print("📡 [LIVE LIST] GET → $url");

    try {
      final response = await http.get(
        url,
        headers: {
          "accept": "application/json",
        },
      );

      print("📡 [LIVE LIST] Status: ${response.statusCode}");
      print("📩 [LIVE LIST] Body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        return data
            .map((e) => LiveAstrologerModel.fromJson(e))
            .toList();
      } else {
        throw Exception("Failed to fetch live astrologers: ${response.body}");
      }
    } catch (e, st) {
      print("❌ [LIVE LIST] Exception: $e");
      print(st);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> joinLive({
    required String astroId,
  }) async {
    await _loadCredentials(); // loads _userId & _accessToken

    final url = Uri.parse("https://fastapi.jyotishionline.com/agora/live/join");

    final body = {
      "astro_id": astroId,
      "user_id": _userId, // can be null → backend supports guests
    };

    print("🎥 [JOIN LIVE] URL → $url");
    print("🎥 [JOIN LIVE] Body → ${jsonEncode(body)}");

    final response = await http.post(
      url,
      headers: {
        "accept": "application/json",
        "Content-Type": "application/json",
        if (_accessToken != null) "Authorization": "Bearer $_accessToken",
      },
      body: jsonEncode(body),
    );

    print("🎥 [JOIN LIVE] Status → ${response.statusCode}");
    print("🎥 [JOIN LIVE] Response → ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to join live: ${response.body}");
    }
  }


  /// 🔹 Fetch Home Banners (Astrologer Side)
  Future<List<Map<String, dynamic>>> getHomeBanners() async {
    final url = Uri.parse(FastApiEndpoints.homeBanners);


    print("📤 Fetching Home Banners...");
    print("🔗 URL: $url");

    try {
      final res = await http.get(
        url,
        headers: {
          "accept": "application/json",
        },
      );

      print("⬅️ Status Code: ${res.statusCode}");
      print("⬅️ Response: ${res.body}");

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);

        if (decoded is List) {
          return List<Map<String, dynamic>>.from(decoded);
        }

        return [];
      } else {
        print("❌ Error fetching banners: ${res.body}");
        return [];
      }
    } catch (e) {
      print("🔥 Exception in getHomeBanners: $e");
      return [];
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
  }

  /// 🔹 Fetch Online Astrologers
  Future<List<OnlineAstrologerModel>> fetchOnlineAstrologers() async {
    final url = Uri.parse(FastApiEndpoints.onlineAstrologers);

    print("📡 [ONLINE ASTROLOGERS] GET → $url");

    try {
      final response = await http.get(
        url,
        headers: {
          "accept": "application/json",
        },
      );

      print("📡 Status: ${response.statusCode}");
      print("📩 Body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        final astrologers = data
            .map((json) => OnlineAstrologerModel.fromJson(json))
            .toList();

        print("✅ Online astrologers fetched: ${astrologers.length}");
        return astrologers;
      } else {
        print("❌ Failed to fetch online astrologers: ${response.body}");
        throw Exception("Failed to fetch online astrologers: ${response.body}");
      }
    } catch (e, st) {
      print("🔥 Exception in fetchOnlineAstrologers: $e");
      print(st);
      rethrow;
    }
  }

}
