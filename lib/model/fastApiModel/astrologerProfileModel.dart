class Astrologer {
  final String astroId;
  final String userId;
  final String name;

  final String? contactNo;
  final bool isContactVerified;
  final DateTime? birthDate;

  final String? primarySkill;
  final String? languageKnown;
  final String? profileImage;

  final double chatCharge;
  final double audioCallCharge;
  final double videoCallCharge;

  /// Extra rates in the payload
  final double? videoCallRate; // sometimes separate from videoCallCharge
  final double? reportRate;

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

  final bool? isActive;
  final bool? isDelete;

  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  final String? createdBy;
  final String? modifiedBy;
  final String? nameofplateform;
  final String? referedPerson;

  final String? chatStatus;
  final String? chatWaitTime;
  final String? callStatus;
  final String? callWaitTime;

  final String? availabilitiesId;

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
    required this.chatCharge,
    required this.audioCallCharge,
    required this.videoCallCharge,
    this.videoCallRate,
    this.reportRate,
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
    this.isActive,
    this.isDelete,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.createdBy,
    this.modifiedBy,
    this.nameofplateform,
    this.referedPerson,
    this.chatStatus,
    this.chatWaitTime,
    this.callStatus,
    this.callWaitTime,
    this.availabilitiesId,
  });

  /// Helpers to safely parse dynamic types from inconsistent APIs
  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.trim());
    return null;
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim());
    return null;
  }

  static bool _toBool(dynamic v, {bool fallback = false}) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final s = v.toLowerCase().trim();
      if (s == 'true' || s == '1' || s == 'yes') return true;
      if (s == 'false' || s == '0' || s == 'no') return false;
    }
    return fallback;
  }

  static DateTime? _toDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String && v.isNotEmpty) {
      try {
        return DateTime.parse(v);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  factory Astrologer.fromJson(Map<String, dynamic> json) {
    return Astrologer(
      astroId: (json["astro_id"] ?? json["astroId"] ?? "").toString(),
      userId: (json["user_id"] ?? json["userId"] ?? "").toString(),
      name: (json["name"] ?? "Unknown Astrologer").toString(),

      contactNo: json["contactNo"]?.toString(),
      isContactVerified: _toBool(json["isContactVerified"], fallback: false),

      birthDate: _toDate(json["birthDate"]),

      primarySkill: json["primarySkill"]?.toString(),
      languageKnown: json["languageKnown"]?.toString(),
      profileImage: json["profileImage"]?.toString(),

      chatCharge: _toDouble(json["chatCharge"]) ?? 0.0,
      audioCallCharge: _toDouble(json["audioCallCharge"]) ?? 0.0,
      videoCallCharge: _toDouble(json["videoCallCharge"]) ?? 0.0,

      videoCallRate: _toDouble(json["videoCallRate"]),
      reportRate: _toDouble(json["reportRate"]),

      experienceInYears: _toInt(json["experienceInYears"]),
      currentCity: json["currentCity"]?.toString(),
      highestQualification: json["highestQualification"]?.toString(),
      learnAstrology: json["learnAstrology"]?.toString(),

      astrologerCategoryId: json["astrologerCategoryId"]?.toString(),

      instaProfileLink: json["instaProfileLink"]?.toString(),
      facebookProfileLink: json["facebookProfileLink"]?.toString(),
      linkedInProfileLink: json["linkedInProfileLink"]?.toString(),
      youtubeChannelLink: json["youtubeChannelLink"]?.toString(),
      websiteProfileLink: json["websiteProfileLink"]?.toString(),

      minimumEarning: _toDouble(json["minimumEarning"]),
      maximumEarning: _toDouble(json["maximumEarning"]),
      monthlyEarning: json["monthlyEarning"]?.toString(),

      loginBio: json["loginBio"]?.toString(),
      currentlyworkingfulltimejob: json["currentlyworkingfulltimejob"]?.toString(),
      goodQuality: json["goodQuality"]?.toString(),
      whatwillDo: json["whatwillDo"]?.toString(),

      isVerified: _toBool(json["isVerified"], fallback: false),
      totalOrder: _toInt(json["totalOrder"]) ?? 0,
      country: json["country"]?.toString(),

      isActive: json.containsKey("isActive") ? _toBool(json["isActive"]) : null,
      isDelete: json.containsKey("isDelete") ? _toBool(json["isDelete"]) : null,

      createdAt: _toDate(json["created_at"]),
      updatedAt: _toDate(json["updated_at"]),
      deletedAt: _toDate(json["deleted_at"]),

      createdBy: json["createdBy"]?.toString(),
      modifiedBy: json["modifiedBy"]?.toString(),
      nameofplateform: json["nameofplateform"]?.toString(),
      referedPerson: json["referedPerson"]?.toString(),

      chatStatus: json["chatStatus"]?.toString(),
      chatWaitTime: json["chatWaitTime"]?.toString(),
      callStatus: json["callStatus"]?.toString(),
      callWaitTime: json["callWaitTime"]?.toString(),

      availabilitiesId: json["availabilitiesId"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "astro_id": astroId,
      "user_id": userId,
      "name": name,

      "contactNo": contactNo,
      "isContactVerified": isContactVerified,

      "birthDate": birthDate?.toIso8601String(),

      "primarySkill": primarySkill,
      "languageKnown": languageKnown,
      "profileImage": profileImage,

      "chatCharge": chatCharge,
      "audioCallCharge": audioCallCharge,
      "videoCallCharge": videoCallCharge,

      "videoCallRate": videoCallRate,
      "reportRate": reportRate,

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

      "isActive": isActive,
      "isDelete": isDelete,

      "created_at": createdAt?.toIso8601String(),
      "updated_at": updatedAt?.toIso8601String(),
      "deleted_at": deletedAt?.toIso8601String(),

      "createdBy": createdBy,
      "modifiedBy": modifiedBy,
      "nameofplateform": nameofplateform,
      "referedPerson": referedPerson,

      "chatStatus": chatStatus,
      "chatWaitTime": chatWaitTime,
      "callStatus": callStatus,
      "callWaitTime": callWaitTime,

      "availabilitiesId": availabilitiesId,
    };
  }

  Astrologer copyWith({
    String? astroId,
    String? userId,
    String? name,
    String? contactNo,
    bool? isContactVerified,
    DateTime? birthDate,
    String? primarySkill,
    String? languageKnown,
    String? profileImage,
    double? chatCharge,
    double? audioCallCharge,
    double? videoCallCharge,
    double? videoCallRate,
    double? reportRate,
    int? experienceInYears,
    String? currentCity,
    String? highestQualification,
    String? learnAstrology,
    String? astrologerCategoryId,
    String? instaProfileLink,
    String? facebookProfileLink,
    String? linkedInProfileLink,
    String? youtubeChannelLink,
    String? websiteProfileLink,
    double? minimumEarning,
    double? maximumEarning,
    String? monthlyEarning,
    String? loginBio,
    String? currentlyworkingfulltimejob,
    String? goodQuality,
    String? whatwillDo,
    bool? isVerified,
    int? totalOrder,
    String? country,
    bool? isActive,
    bool? isDelete,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    String? createdBy,
    String? modifiedBy,
    String? nameofplateform,
    String? referedPerson,
    String? chatStatus,
    String? chatWaitTime,
    String? callStatus,
    String? callWaitTime,
    String? availabilitiesId,
  }) {
    return Astrologer(
      astroId: astroId ?? this.astroId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      contactNo: contactNo ?? this.contactNo,
      isContactVerified: isContactVerified ?? this.isContactVerified,
      birthDate: birthDate ?? this.birthDate,
      primarySkill: primarySkill ?? this.primarySkill,
      languageKnown: languageKnown ?? this.languageKnown,
      profileImage: profileImage ?? this.profileImage,
      chatCharge: chatCharge ?? this.chatCharge,
      audioCallCharge: audioCallCharge ?? this.audioCallCharge,
      videoCallCharge: videoCallCharge ?? this.videoCallCharge,
      videoCallRate: videoCallRate ?? this.videoCallRate,
      reportRate: reportRate ?? this.reportRate,
      experienceInYears: experienceInYears ?? this.experienceInYears,
      currentCity: currentCity ?? this.currentCity,
      highestQualification:
      highestQualification ?? this.highestQualification,
      learnAstrology: learnAstrology ?? this.learnAstrology,
      astrologerCategoryId:
      astrologerCategoryId ?? this.astrologerCategoryId,
      instaProfileLink: instaProfileLink ?? this.instaProfileLink,
      facebookProfileLink:
      facebookProfileLink ?? this.facebookProfileLink,
      linkedInProfileLink:
      linkedInProfileLink ?? this.linkedInProfileLink,
      youtubeChannelLink:
      youtubeChannelLink ?? this.youtubeChannelLink,
      websiteProfileLink:
      websiteProfileLink ?? this.websiteProfileLink,
      minimumEarning: minimumEarning ?? this.minimumEarning,
      maximumEarning: maximumEarning ?? this.maximumEarning,
      monthlyEarning: monthlyEarning ?? this.monthlyEarning,
      loginBio: loginBio ?? this.loginBio,
      currentlyworkingfulltimejob: currentlyworkingfulltimejob ??
          this.currentlyworkingfulltimejob,
      goodQuality: goodQuality ?? this.goodQuality,
      whatwillDo: whatwillDo ?? this.whatwillDo,
      isVerified: isVerified ?? this.isVerified,
      totalOrder: totalOrder ?? this.totalOrder,
      country: country ?? this.country,
      isActive: isActive ?? this.isActive,
      isDelete: isDelete ?? this.isDelete,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      createdBy: createdBy ?? this.createdBy,
      modifiedBy: modifiedBy ?? this.modifiedBy,
      nameofplateform: nameofplateform ?? this.nameofplateform,
      referedPerson: referedPerson ?? this.referedPerson,
      chatStatus: chatStatus ?? this.chatStatus,
      chatWaitTime: chatWaitTime ?? this.chatWaitTime,
      callStatus: callStatus ?? this.callStatus,
      callWaitTime: callWaitTime ?? this.callWaitTime,
      availabilitiesId: availabilitiesId ?? this.availabilitiesId,
    );
  }
}
