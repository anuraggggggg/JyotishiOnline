// lib/utils/fastapi_endpoints.dart

class FastApiEndpoints {



  static const String verifyLoginOtp =
      "$fastApiBaseUrl/api/v1/auth/verify-otp";
  // Base URL
  static const String fastApiBaseUrl = "https://fastapi.jyotishionline.com";

  // ---------------- CUSTOMER NOTIFICATIONS ----------------
  /// Fetch notifications for a customer
  /// Replace {user_id} dynamically when calling
  static String customerNotifications(String userId) =>
      "$fastApiBaseUrl/api/v1/$userId";
  static const String sendMoney = "$fastApiBaseUrl/api/v1/send-money";
  // ---------------- LOGIN ----------------
  static const String login = "$fastApiBaseUrl/api/v1/auth/login";
  static const String loginOtp = "$fastApiBaseUrl/api/v1/auth/login-otp";

  static const String sendMobileOtp = "$fastApiBaseUrl/api/v1/auth/send-otp";
  // static const String customerSendOtp =
  //     "$fastApiBaseUrl/api/v1/customer-send-otp";
  // static const String customerVerifyOtp =
  //     "$fastApiBaseUrl/api/v1/customer-verify-otp";
  static const String verifyMobileOtp =
      "$fastApiBaseUrl/api/v1/auth/verify-otp";

  /// POST → Create user review
  static const String userReviews =
      "$fastApiBaseUrl/api/v1/userreviews";

  /// Block or Report Astrologer
  static const String blockAstrologer = "$fastApiBaseUrl/api/v1/block";
  static const String reportAstrologer = "$fastApiBaseUrl/api/v1/block/report";


  // ---------------- SESSION / CALL ----------------
  static const String createSession = "$fastApiBaseUrl/api/v1/create";

  static const String appVersion = "$fastApiBaseUrl/api/v1/astro/app-version";

  // ---------------- USERS ----------------
  // ----------------ALL CUSTOMER DETAILS ----------------
  static const String customerDetails =
      "$fastApiBaseUrl/api/v1/customerdetails";

  static String customerDetailsById(String id) =>
      "$fastApiBaseUrl/api/v1/customerdetails/$id";

// --------------GET ALL ASTROLOGERS ----------------
  static const String allAstrologers =
      "$fastApiBaseUrl/api/v1/astro/astrologers";

  static const String astrologerById =
      "$fastApiBaseUrl/api/v1/astro/astrologers/";

  // ---------------- ALL WALLET DETAILS ----------------

  static const String walletTransfer = "$fastApiBaseUrl/api/v1/wallet/transfer";

  static const String walletTransactions =
      "$fastApiBaseUrl/api/v1/wallettransactions/user";




  static String updateWallet(String userId) =>
      "$fastApiBaseUrl/api/v1/userwallets/$userId";

  static const String allWalletDetails =
      "$fastApiBaseUrl/api/v1/userwallets"; // Fetch all wallet details

  static const String userWalletDetails =
      "$fastApiBaseUrl/api/v1/userwallets/"; // Append wallet ID to

  static const String creditWallet = "$fastApiBaseUrl/api/v1/userwallets/";

  static const String debitWallet = "$fastApiBaseUrl/api/v1/userwallets/";

  // ---------------- CHAT ROUTER ----------------

// Get chat history (with pagination)
  static String getChatHistory(String roomId, {int page = 1, int size = 20}) =>
      "$fastApiBaseUrl/chat/$roomId?page=$page&size=$size";

// Get last message in a chat room
  static String getLastMessage(String roomId) =>
      "$fastApiBaseUrl/chat/$roomId/last";

// Mark messages as read in a chat room
  static String markMessagesAsRead(String roomId) =>
      "$fastApiBaseUrl/chat/$roomId/read";

// Send a new message
  static const String sendMessage = "$fastApiBaseUrl/chat/send";


  // ---------------- CURRENT USER DETAILS ----------------

  static String currentUserDetails(String userId) =>
      "$fastApiBaseUrl/api/v1/customerdetails/get-by-userid/$userId";

  static const String signupStep1 = "$fastApiBaseUrl/api/v1/users/signup/step1";

  static const String signupStep2 = "$fastApiBaseUrl/api/v1/users/signup/step2";
  static const String resendOtp =
      "$fastApiBaseUrl/api/v1/users/signup/resend-otp";
  static const String signupStep3 = "$fastApiBaseUrl/api/v1/users/signup/step3";
  static const String signupStep4 = "$fastApiBaseUrl/api/v1/users/signup/step4";
  static const String getUsers = "$fastApiBaseUrl/api/v1/users/get_users";
  static const String genderCounts =
      "$fastApiBaseUrl/api/v1/users/gender-counts";
  static const String sendMatchRequest =
      "$fastApiBaseUrl/api/v1/users/requests/send";
  static const String respondMatchRequest =
      "$fastApiBaseUrl/api/v1/users/requests/respond";
  static const String saveUnsaveProfile =
      "$fastApiBaseUrl/api/v1/users/save-unsave";
  static const String blockUnblockUser =
      "$fastApiBaseUrl/api/v1/users/block-unblock";
  static const String getBlockedUsers =
      "$fastApiBaseUrl/api/v1/users/users/blocked";
  static const String getSavedProfiles =
      "$fastApiBaseUrl/api/v1/users/users/saved";
  static const String getReceivedRequests =
      "$fastApiBaseUrl/api/v1/users/connections/received";
  static const String getSentRequests =
      "$fastApiBaseUrl/api/v1/users/connections/sent";
  static const String getConnectedUsers =
      "$fastApiBaseUrl/api/v1/users/connections/connected";
  static const String getRecommendedUsers =
      "$fastApiBaseUrl/api/v1/users/recommended";
  static const String getNearbyUsers = "$fastApiBaseUrl/api/v1/users/nearby";
  static const String getNewProfiles = "$fastApiBaseUrl/api/v1/users/new";
  static const String editProfile = "$fastApiBaseUrl/api/v1/users/edit-profile";
  static const String getMyViews = "$fastApiBaseUrl/api/v1/users/my-views";
  static const String getUserNotifications =
      "$fastApiBaseUrl/api/v1/users/notification/"; // Append status
  static const String getUsersList = "$fastApiBaseUrl/api/v1/users/users/list";
  static const String viewUserProfile =
      "$fastApiBaseUrl/api/v1/users/view_profile/"; // Append userId
  static const String getProfiles = "$fastApiBaseUrl/api/v1/users/profiles";
  static const String receiveUserData =
      "$fastApiBaseUrl/api/v1/users/api/receive_user_data";
  static const String appPay = "$fastApiBaseUrl/api/v1/users/app_pay";
  static const String paymentSuccess =
      "$fastApiBaseUrl/api/v1/users/api/payment_success";
  static const String sendNotification =
      "$fastApiBaseUrl/api/v1/users/send-notification";
  static const String recoverAccount =
      "$fastApiBaseUrl/api/v1/users/api/recover_account";
  static const String recoverAccountVerify =
      "$fastApiBaseUrl/api/v1/users/api/recover_account_verify";
  static const String deleteUserProfile =
      "$fastApiBaseUrl/api/v1/users/api/delete_user_profile";
  static const String worldMobileCodes =
      "$fastApiBaseUrl/api/v1/users/api/world_mobile_codes";
  static const String uploadUsersExcel =
      "$fastApiBaseUrl/api/v1/users/upload-users-excel";
  static const String contactForm = "$fastApiBaseUrl/api/v1/users/contact";
  static const String checkAndSendMessage =
      "$fastApiBaseUrl/api/v1/users/chat/check-send/"; // Append receiver_id

  // 🔔 Register customer FCM token
  static const String registerCustomerFcmToken =
      "$fastApiBaseUrl/Customer_notification/register-token";


  // ---------------- ADMIN ----------------f
  static const String adminGetUsers =
      "$fastApiBaseUrl/api/v1/admin/admin/users";
  static const String adminGetProfileById =
      "$fastApiBaseUrl/api/v1/admin/admin/users/"; // Append user_id
  static const String adminUpdateUserMembership =
      "$fastApiBaseUrl/api/v1/admin/admin/users/"; // Append user_id
  static const String adminDeleteUser =
      "$fastApiBaseUrl/api/v1/admin/admin/users/"; // Append user_id
  static const String adminGetUserPayments =
      "$fastApiBaseUrl/api/v1/admin/admin/users/"; // Append user_id + "/payments"
  static const String adminGetAllPayments =
      "$fastApiBaseUrl/api/v1/admin/admin/payments";



  /// 🔹 Signup With Full Details (creates User, CustomerDetail & Wallet)
  static const String signupWithDetails =
      "$fastApiBaseUrl/api/v1/customerdetails";


  static const String sendAstrologerNotification =
      "$fastApiBaseUrl/Astrologer_notification/send-notification";

  // --------------- BANNERS ----------------
  static const String homeBanners = "$fastApiBaseUrl/api/v1/astro/home-banner";

  // ---------------- ONLINE ASTROLOGERS ----------------
  static const String onlineAstrologers =
      "$fastApiBaseUrl/astro_online/astrologers/online";

  // ---------------- COSMIC SERVICES ----------------
  static const String cosmicServices = "$fastApiBaseUrl/api/v1/cosmic-services";

  // ---------------- CUSTOMER OTP (NEW FLOW) ----------------

// Send OTP to customer (Signup + Login)
  static const String customerSendOtp =
      "$fastApiBaseUrl/api/v1/auth/send-otp";

// Verify OTP for customer
  static const String customerVerifyOtp =
      "$fastApiBaseUrl/api/v1/customer/verify-otp";

  // Verify OTP for customer login (form-urlencoded)
  static const String verifyLoginOTP =
      "$fastApiBaseUrl/api/v1/customer/verify-otp";
}


