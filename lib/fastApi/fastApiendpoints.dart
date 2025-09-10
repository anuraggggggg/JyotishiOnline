// lib/utils/fastapi_endpoints.dart

class FastApiEndpoints {
  // Base URL
  static const String fastApiBaseUrl = "https://fastapi.jyotishionline.com";

  // ---------------- LOGIN ----------------
  static const String login = "$fastApiBaseUrl/api/v1/auth/login";
  static const String loginOtp = "$fastApiBaseUrl/api/v1/auth/login-otp";
  static const String sendMobileOtp = "$fastApiBaseUrl/api/v1/auth/send-otp";
  static const String verifyMobileOtp =
      "$fastApiBaseUrl/api/v1/auth/verify-otp";

  // ---------------- USERS ----------------
  // ----------------ALL CUSTOMER DETAILS ----------------
  static const String customerDetails =
      "$fastApiBaseUrl/api/v1/customerdetails";

  // ---------------- ALL WALLET DETAILS ----------------

  static String updateWallet(String userId) =>
      "$fastApiBaseUrl/api/v1/userwallets/$userId";

  static const String allWalletDetails =
      "$fastApiBaseUrl/api/v1/userwallets"; // Fetch all wallet details

  static const String userWalletDetails =
      "$fastApiBaseUrl/api/v1/userwallets/"; // Append wallet ID to


  static const String creditWallet =
      "$fastApiBaseUrl/api/v1/userwallets/";

  static const String debitWallet =
      "$fastApiBaseUrl/api/v1/userwallets/";

  // ---------------- CURRENT USER DETAILS ----------------

  static String currentUserDetails(String userId) =>
      "$fastApiBaseUrl/api/v1/customerdetails/$userId";

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

  // ---------------- CHAT ----------------
  static const String chatUsersWithLastMessage =
      "$fastApiBaseUrl/api/v1/chat/users_with_last_message";
  static const String getChatHistory =
      "$fastApiBaseUrl/api/v1/chat/chat/history/"; // Append other_user_id
  static const String generateAgoraTokenVideo =
      "$fastApiBaseUrl/api/v1/chat/agora/token/videogenerate";
  static const String generateAgoraTokenVoice =
      "$fastApiBaseUrl/api/v1/chat/agora/token/Voicegenerate";
  static const String userVideoCallStatus =
      "$fastApiBaseUrl/api/v1/chat/uservideocallstatus";
  static const String userAudioCallStatus =
      "$fastApiBaseUrl/api/v1/chat/useraudiocallstatus";

  // ---------------- ADMIN ----------------
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
}
