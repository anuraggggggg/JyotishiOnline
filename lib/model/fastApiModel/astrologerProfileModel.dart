class Astrologer {
  final String astroId;
  final String name;
  final String? profileImage;
  final String? primarySkill;
  final String? languageKnown;
  final int? experienceInYears;
  final double? charge;
  final String? currentCity;

  Astrologer({
    required this.astroId,
    required this.name,
    this.profileImage,
    this.primarySkill,
    this.languageKnown,
    this.experienceInYears,
    this.charge,
    this.currentCity,
  });

  factory Astrologer.fromJson(Map<String, dynamic> json) {
    return Astrologer(
      astroId: json["astro_id"] ?? "",
      name: json["name"] ?? "Unknown",
      profileImage: json["profileImage"],
      primarySkill: json["primarySkill"],
      languageKnown: json["languageKnown"],
      experienceInYears: json["experienceInYears"],
      charge: (json["charge"] ?? 0).toDouble(),
      currentCity: json["currentCity"],
    );
  }
}
