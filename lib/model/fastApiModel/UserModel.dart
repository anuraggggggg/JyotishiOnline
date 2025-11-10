import 'dart:convert';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String contactNo;
  final String gender;
  final String countryCode;
  final String role;           // can be "user" or "1" etc. -> keep as String
  final String fcmToken;
  final bool isDeleted;
  final bool isOnline;
  final bool isActive;
  final int unreadCount;
  final DateTime? lastSeen;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.contactNo,
    required this.gender,
    required this.countryCode,
    required this.role,
    required this.fcmToken,
    required this.isDeleted,
    required this.isOnline,
    required this.isActive,
    required this.unreadCount,
    required this.lastSeen,
  });

  /// Safe helpers for mixed/nullable API fields
  static String _asString(dynamic v) => v == null ? '' : v.toString();
  static bool _asBool(dynamic v) {
    if (v is bool) return v;
    final s = v?.toString().toLowerCase();
    if (s == 'true') return true;
    if (s == 'false') return false;
    return false;
  }
  static int _asInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
  static DateTime? _asDate(dynamic v) {
    final s = v?.toString();
    if (s == null || s.isEmpty) return null;
    return DateTime.tryParse(s);
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: _asString(json['id']),
      email: _asString(json['email']),
      name: _asString(json['name']),
      contactNo: _asString(json['contactNo']),
      gender: _asString(json['gender']),              // null -> ''
      countryCode: _asString(json['countryCode']),    // null -> ''
      role: _asString(json['role']),                  // "user" or "1"
      fcmToken: _asString(json['fcm_token']),         // null -> ''
      isDeleted: _asBool(json['is_deleted']),
      isOnline: _asBool(json['is_online']),
      isActive: _asBool(json['is_active']),
      unreadCount: _asInt(json['unread_count']),
      lastSeen: _asDate(json['lastSeen']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'contactNo': contactNo,
    'gender': gender,
    'countryCode': countryCode,
    'role': role,
    'fcm_token': fcmToken,
    'is_deleted': isDeleted,
    'is_online': isOnline,
    'is_active': isActive,
    'unread_count': unreadCount,
    'lastSeen': lastSeen?.toIso8601String(),
  };

  /// Optional: pretty print for your debug logs
  @override
  String toString() => const JsonEncoder.withIndent('  ').convert(toJson());
}
