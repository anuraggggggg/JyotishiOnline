class LoveCompatibilityModel {
  final String? compatibility;
  final String? report;

  LoveCompatibilityModel({
    this.compatibility,
    this.report,
  });

  factory LoveCompatibilityModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final predictions = data?['daily_love_predictions'] as List<dynamic>?;

    if (predictions == null || predictions.isEmpty) {
      return LoveCompatibilityModel(
        compatibility: null,
        report: null,
      );
    }

    final firstPrediction = predictions.first;

    return LoveCompatibilityModel(
      compatibility: firstPrediction['sign_combination'] as String?,
      report: firstPrediction['prediction'] as String?,
    );
  }
}
