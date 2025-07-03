class DailyPredictionModel {
  final String signName;
  final String date;
  final String prediction;

  DailyPredictionModel({
    required this.signName,
    required this.date,
    required this.prediction,
  });

  factory DailyPredictionModel.fromJson(Map<String, dynamic> json) {
    return DailyPredictionModel(
      signName: json['daily_prediction']['sign_name'],
      date: json['daily_prediction']['date'],
      prediction: json['daily_prediction']['prediction'],
    );
  }
}
