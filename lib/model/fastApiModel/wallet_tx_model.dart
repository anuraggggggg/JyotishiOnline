import 'dart:convert';

class WalletTxModel {
  final int id;
  final double amount;
  final String transactionType;
  final String status;
  final bool isCredit;
  final DateTime createdAt;
  final String? userName;
  final String duration;

  WalletTxModel({
    required this.id,
    required this.amount,
    required this.transactionType,
    required this.status,
    required this.isCredit,
    required this.createdAt,
    this.userName,
    required this.duration,
  });

  factory WalletTxModel.fromJson(Map<String, dynamic> json) {
    return WalletTxModel(
      id: json['id'] ?? 0,
      // API sends 200.0 (double) or 200 (int). .toDouble() handles both.
      amount: (json['amount'] ?? 0).toDouble(),
      transactionType: json['transactionType'] ?? '',
      status: json['status'] ?? '',
      // Handles both boolean true/false and integer 1/0
      isCredit: json['isCredit'] == true || json['isCredit'] == 1,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      userName: json['userName'],
      duration: json['duration'] ?? '00:00:00',
    );
  }
}