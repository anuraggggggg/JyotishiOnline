class LoginResponse {
  final String accessToken;
  final String tokenType;
  final User user;

  LoginResponse({
    required this.accessToken,
    required this.tokenType,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'] ?? '',
      tokenType: json['token_type'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
    );
  }
}

class User {
  final String id;
  final String contactNo;
  final String role;

  // email is OPTIONAL because OTP API does NOT return it
  final String? email;

  User({
    required this.id,
    required this.contactNo,
    required this.role,
    this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      contactNo: json['contactNo'] ?? '',
      role: json['role'] ?? 'user', // default fallback
      email: json['email'],         // may be null
    );
  }
}

