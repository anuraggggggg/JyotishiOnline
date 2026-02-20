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
      astroId: json['astro_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown',
      profileImage: json['profileImage']?.toString(),
      primarySkill: json['primarySkill']?.toString(),

      // ✅ Flexible language mapping
      languageKnown: json['languageKnown']?.toString() ??
          json['language_known']?.toString() ??
          json['languages']?.toString(),

      experienceInYears: int.tryParse(json['experienceInYears'].toString()) ?? 0,

      chatCharge: (json['chatCharge'] ?? 0).toDouble(),
      audioCallCharge: (json['audioCallCharge'] ?? 0).toDouble(),
      videoCallCharge: (json['videoCallCharge'] ?? 0).toDouble(),

      overallRating: (json['overallRating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,

      currentCity: json['currentCity']?.toString(),
    );
  }

}
