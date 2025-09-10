import 'dart:convert';

import 'package:AstrowayCustomer/fastApi/fastApiServices.dart';

class WalletModel {
  final String id;
  final int amount;
  final bool isActive;
  final bool isDelete;
  final DateTime createdAt;
  final DateTime updatedAt;

  WalletModel({
    required this.id,
    required this.amount,
    required this.isActive,
    required this.isDelete,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] ?? '',
      amount: (json['amount'] ?? 0).toInt(), // Convert double to int
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

void printWallets(String responseBody) {
  final List<dynamic> data = jsonDecode(responseBody);
  final wallets = data.map((json) => WalletModel.fromJson(json)).toList();

  print("💰 Wallet Details:\n");
  for (var wallet in wallets) {
    print(wallet); // prints each wallet using WalletModel.toString()
  }
}

// Example usage
void fetchAndPrintWallets() async {
  final fastApiService = FastAPIServices(); // your service class

  try {
    final wallets = await fastApiService
        .getAllWalletDetails(); // now returns List<WalletModel>

    print("💰 Wallet Details:\n");
    for (var wallet in wallets) {
      print(wallet); // uses WalletModel.toString()
    }
  } catch (e) {
    print("❌ Error fetching wallets: $e");
  }
}
