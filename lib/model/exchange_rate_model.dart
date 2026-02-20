class ExchangeRateModel {
  final double usdRate;

  ExchangeRateModel({required this.usdRate});

  factory ExchangeRateModel.fromJson(Map<String, dynamic> json) {
    return ExchangeRateModel(
      usdRate: json['rates']['USD'].toDouble(),
    );
  }
}
