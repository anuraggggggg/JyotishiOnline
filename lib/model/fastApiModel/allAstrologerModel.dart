class GetAllAstrologerModel {
  final String astroId;
  final String name;
  final String? profileImage;
  final String? primarySkill;
  final String? languageKnown;
  final int experienceInYears;
  final double chatCharge;
  final double audioCallCharge;
  final double videoCallCharge;
  final double overallRating;
  final int totalReviews;
  final String? currentCity;

  GetAllAstrologerModel({
    required this.astroId,
    required this.name,
    this.profileImage,
    this.primarySkill,
    this.languageKnown,
    required this.experienceInYears,
    required this.chatCharge,
    required this.audioCallCharge,
    required this.videoCallCharge,
    required this.overallRating,
    required this.totalReviews,
    this.currentCity,
  });

  factory GetAllAstrologerModel.fromJson(Map<String, dynamic> json) {
    return GetAllAstrologerModel(
      astroId: json['astro_id'] ?? '',
      name: json['name'] ?? 'Unknown',
      profileImage: json['profileImage'],
      primarySkill: json['primarySkill'],
      languageKnown: json['languageKnown'],
      experienceInYears: json['experienceInYears'] ?? 0,

      // ✅ FIXED FIELD NAMES
      chatCharge: (json['chatCharge'] ?? 0).toDouble(),
      audioCallCharge: (json['audioCallCharge'] ?? 0).toDouble(),
      videoCallCharge: (json['videoCallCharge'] ?? 0).toDouble(),

      // ✅ NEW FIELDS
      overallRating: (json['overallRating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,

      currentCity: json['currentCity'],
    );
  }
}
