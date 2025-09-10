import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

// A simple model class to represent the user data from the API response
class UserModel {
  final String email;
  final String name;
  final String id;
  final String contactNo;
  final String gender;
  final String lastSeen;

  UserModel({
    required this.email,
    required this.name,
    required this.id,
    required this.contactNo,
    required this.gender,
    required this.lastSeen,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'] as String,
      name: json['name'] as String,
      id: json['id'] as String,
      contactNo: json['contactNo'] as String,
      gender: json['gender'] as String,
      lastSeen: json['lastSeen'] as String,
    );
  }
}

