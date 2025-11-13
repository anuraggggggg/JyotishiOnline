class LiveAstrologerModel {
  final String astroId;
  final String name;
  final String profileImage;
  final String liveChannel;
  final String liveStartedAt;
  final String primarySkill;
  final String languageKnown;
  final int experienceInYears;
  final String currentCity;
  final String loginBio;
  final int videoCallRate;
  final bool isChatEnabled;

  LiveAstrologerModel({
    required this.astroId,
    required this.name,
    required this.profileImage,
    required this.liveChannel,
    required this.liveStartedAt,
    required this.primarySkill,
    required this.languageKnown,
    required this.experienceInYears,
    required this.currentCity,
    required this.loginBio,
    required this.videoCallRate,
    required this.isChatEnabled,
  });

  factory LiveAstrologerModel.fromJson(Map<String, dynamic> json) {
    return LiveAstrologerModel(
      astroId: json['astro_id'] ?? "",
      name: json['name'] ?? "",
      profileImage: json['profileImage'] ?? "",
      liveChannel: json['liveChannel'] ?? "",
      liveStartedAt: json['liveStartedAt'] ?? "",
      primarySkill: json['primarySkill'] ?? "",
      languageKnown: json['languageKnown'] ?? "",
      experienceInYears: json['experienceInYears'] ?? 0,
      currentCity: json['currentCity'] ?? "",
      loginBio: json['loginBio'] ?? "",
      videoCallRate: json['videoCallRate'] ?? 0,
      isChatEnabled: json['isChatEnabled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "astro_id": astroId,
      "name": name,
      "profileImage": profileImage,
      "liveChannel": liveChannel,
      "liveStartedAt": liveStartedAt,
      "primarySkill": primarySkill,
      "languageKnown": languageKnown,
      "experienceInYears": experienceInYears,
      "currentCity": currentCity,
      "loginBio": loginBio,
      "videoCallRate": videoCallRate,
      "isChatEnabled": isChatEnabled,
    };
  }
}
