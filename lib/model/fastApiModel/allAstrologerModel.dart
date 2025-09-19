class GetAllAstrologerModel {
  final String id;
  final String name;
  final String profileImage;
  final String primarySkill;
  final String languageKnown;
  final int experienceInYears;
  final int charge;
  final String currentCity;

  GetAllAstrologerModel({
    required this.id,
    required this.name,
    required this.profileImage,
    required this.primarySkill,
    required this.languageKnown,
    required this.experienceInYears,
    required this.charge,
    required this.currentCity,
  });

  factory GetAllAstrologerModel.fromJson(Map<String, dynamic> json) {
    return GetAllAstrologerModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      profileImage: json['profileImage'] ?? '',
      primarySkill: json['primarySkill'] ?? '',
      languageKnown: json['languageKnown'] ?? '',
      experienceInYears: json['experienceInYears'] ?? 0,
      charge: json['charge'] ?? 0,
      currentCity: json['currentCity'] ?? '',
    );
  }
}
