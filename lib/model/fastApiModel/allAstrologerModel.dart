class GetAllAstrologerModel {
  final String astroId;
  final String name;
  final String? profileImage;
  final String? primarySkill;
  final String? languageKnown;
  final int? experienceInYears;
  final double? charge;
  final String? currentCity;

  GetAllAstrologerModel({
    required this.astroId,
    required this.name,
    this.profileImage,
    this.primarySkill,
    this.languageKnown,
    this.experienceInYears,
    this.charge,
    this.currentCity,
  });

  factory GetAllAstrologerModel.fromJson(Map<String, dynamic> json) {
    return GetAllAstrologerModel(
      astroId: json['astro_id'] ?? '', // ✅ map astro_id here
      name: json['name'] ?? 'Unknown',
      profileImage: json['profileImage'],
      primarySkill: json['primarySkill'],
      languageKnown: json['languageKnown'],
      experienceInYears: json['experienceInYears'],
      charge: (json['charge'] ?? 0).toDouble(),
      currentCity: json['currentCity'],
    );
  }
}
