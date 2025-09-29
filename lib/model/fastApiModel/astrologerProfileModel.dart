class Astrologer {
  final String id;
  final String name;
  final String profileImage;
  final String primarySkill;
  final String languageKnown;
  final int experienceInYears;
  final double charge;
  final String currentCity;

  Astrologer({
    required this.id,
    required this.name,
    required this.profileImage,
    required this.primarySkill,
    required this.languageKnown,
    required this.experienceInYears,
    required this.charge,
    required this.currentCity,
  });

  factory Astrologer.fromJson(Map<String, dynamic> json) {
    return Astrologer(
      id: json['astro_id'] ?? json['user_id'] ?? '',
      name: json['name'] ?? '',
      profileImage: json['profileImage'] ?? '',
      primarySkill: json['primarySkill'] ?? '',
      languageKnown: json['languageKnown'] ?? '',
      experienceInYears: json['experienceInYears'] ?? 0,
      charge: (json['charge'] ?? 0).toDouble(),
      currentCity: json['currentCity'] ?? '',
    );
  }
}
