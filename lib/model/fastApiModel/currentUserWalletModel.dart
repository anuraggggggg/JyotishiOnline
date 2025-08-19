import 'dart:convert';

// Model to represent the current user's wallet details
class CurrentUserWalletModel {
  final String id;
  final int amount;
  final bool isActive;
  final bool isDelete;
  final DateTime createdAt;
  final DateTime updatedAt;

  CurrentUserWalletModel({
    required this.id,
    required this.amount,
    required this.isActive,
    required this.isDelete,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CurrentUserWalletModel.fromJson(Map<String, dynamic> json) {
    return CurrentUserWalletModel(
      id: json['id'] ?? '',
      amount: (json['amount'] ?? 0).toInt(),
      isActive: json['isActive'] ?? false,
      isDelete: json['isDelete'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  @override
  String toString() {
    return '''
💎 Wallet Details
━━━━━━━━━━━━━━━━━━━━━━
🆔 ID        : $id
💰 Amount    : ₹$amount
✅ Active    : ${isActive ? "Yes" : "No"}
🗑️ Deleted   : ${isDelete ? "Yes" : "No"}
📅 Created   : ${createdAt.toLocal()}
🔄 Updated   : ${updatedAt.toLocal()}
━━━━━━━━━━━━━━━━━━━━━━
''';
  }
}
