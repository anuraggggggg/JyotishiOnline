class Astrologer {
  final String astroId;
  final String userId;
  final String name;
  final String? contactNo;
  final bool isContactVerified;
  final String? birthDate;
  final String? primarySkill;
  final String? languageKnown;
  final String? profileImage;
  final double charge;
  final int? experienceInYears;
  final String? currentCity;
  final String? highestQualification;
  final String? learnAstrology;
  final String? astrologerCategoryId;
  final String? instaProfileLink;
  final String? facebookProfileLink;
  final String? linkedInProfileLink;
  final String? youtubeChannelLink;
  final String? websiteProfileLink;
  final double? minimumEarning;
  final double? maximumEarning;
  final String? monthlyEarning;
  final String? loginBio;
  final String? currentlyworkingfulltimejob;
  final String? goodQuality;
  final String? whatwillDo;
  final bool isVerified;
  final int totalOrder;
  final String? country;

  Astrologer({
    required this.astroId,
    required this.userId,
    required this.name,
    this.contactNo,
    required this.isContactVerified,
    this.birthDate,
    this.primarySkill,
    this.languageKnown,
    this.profileImage,
    required this.charge,
    this.experienceInYears,
    this.currentCity,
    this.highestQualification,
    this.learnAstrology,
    this.astrologerCategoryId,
    this.instaProfileLink,
    this.facebookProfileLink,
    this.linkedInProfileLink,
    this.youtubeChannelLink,
    this.websiteProfileLink,
    this.minimumEarning,
    this.maximumEarning,
    this.monthlyEarning,
    this.loginBio,
    this.currentlyworkingfulltimejob,
    this.goodQuality,
    this.whatwillDo,
    required this.isVerified,
    required this.totalOrder,
    this.country,
  });

  factory Astrologer.fromJson(Map<String, dynamic> json) {
    return Astrologer(
      astroId: json["astro_id"] ?? "",
      userId: json["user_id"] ?? "",
      name: json["name"] ?? "Unknown Astrologer",
      contactNo: json["contactNo"],
      isContactVerified: json["isContactVerified"] ?? false,
      birthDate: json["birthDate"],
      primarySkill: json["primarySkill"],
      languageKnown: json["languageKnown"],
      profileImage: json["profileImage"],
      charge: (json["charge"] is String ? double.tryParse(json["charge"]) : json["charge"] ?? 0).toDouble(),
      experienceInYears: json["experienceInYears"],
      currentCity: json["currentCity"],
      highestQualification: json["highestQualification"],
      learnAstrology: json["learnAstrology"],
      astrologerCategoryId: json["astrologerCategoryId"],
      instaProfileLink: json["instaProfileLink"],
      facebookProfileLink: json["facebookProfileLink"],
      linkedInProfileLink: json["linkedInProfileLink"],
      youtubeChannelLink: json["youtubeChannelLink"],
      websiteProfileLink: json["websiteProfileLink"],
      minimumEarning: (json["minimumEarning"] is String ? double.tryParse(json["minimumEarning"]) : json["minimumEarning"])?.toDouble(),
      maximumEarning: (json["maximumEarning"] is String ? double.tryParse(json["maximumEarning"]) : json["maximumEarning"])?.toDouble(),
      monthlyEarning: json["monthlyEarning"]?.toString(),
      loginBio: json["loginBio"],
      currentlyworkingfulltimejob: json["currentlyworkingfulltimejob"],
      goodQuality: json["goodQuality"],
      whatwillDo: json["whatwillDo"],
      isVerified: json["isVerified"] ?? false,
      totalOrder: json["totalOrder"] ?? 0,
      country: json["country"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "astro_id": astroId,
      "user_id": userId,
      "name": name,
      "contactNo": contactNo,
      "isContactVerified": isContactVerified,
      "birthDate": birthDate,
      "primarySkill": primarySkill,
      "languageKnown": languageKnown,
      "profileImage": profileImage,
      "charge": charge,
      "experienceInYears": experienceInYears,
      "currentCity": currentCity,
      "highestQualification": highestQualification,
      "learnAstrology": learnAstrology,
      "astrologerCategoryId": astrologerCategoryId,
      "instaProfileLink": instaProfileLink,
      "facebookProfileLink": facebookProfileLink,
      "linkedInProfileLink": linkedInProfileLink,
      "youtubeChannelLink": youtubeChannelLink,
      "websiteProfileLink": websiteProfileLink,
      "minimumEarning": minimumEarning,
      "maximumEarning": maximumEarning,
      "monthlyEarning": monthlyEarning,
      "loginBio": loginBio,
      "currentlyworkingfulltimejob": currentlyworkingfulltimejob,
      "goodQuality": goodQuality,
      "whatwillDo": whatwillDo,
      "isVerified": isVerified,
      "totalOrder": totalOrder,
      "country": country,
    };
  }
}