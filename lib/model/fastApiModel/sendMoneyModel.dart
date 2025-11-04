class SendMoneyResponse {
  final String message;
  final int transactionId;
  final String transactionType;
  final num userBalance;
  final num astroBalance;
  final DateTime timestamp;

  SendMoneyResponse({
    required this.message,
    required this.transactionId,
    required this.transactionType,
    required this.userBalance,
    required this.astroBalance,
    required this.timestamp,
  });

  factory SendMoneyResponse.fromJson(Map<String, dynamic> json) {
    return SendMoneyResponse(
      message: json['message']?.toString() ?? '',
      transactionId: json['transaction_id'] is int
          ? json['transaction_id'] as int
          : int.tryParse(json['transaction_id']?.toString() ?? '0') ?? 0,
      transactionType: json['transaction_type']?.toString() ?? '',
      userBalance: json['user_balance'] is num
          ? json['user_balance'] as num
          : num.parse(json['user_balance']?.toString() ?? '0'),
      astroBalance: json['astro_balance'] is num
          ? json['astro_balance'] as num
          : num.parse(json['astro_balance']?.toString() ?? '0'),
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
