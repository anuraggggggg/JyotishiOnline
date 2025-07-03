// To parse this JSON data, do
//
//     final vedicDailyHoroscopeModel = vedicDailyHoroscopeModelFromJson(jsonString);

import 'dart:convert';

VedicDailyHoroscopeModel vedicDailyHoroscopeModelFromJson(String str) => VedicDailyHoroscopeModel.fromJson(json.decode(str));

String vedicDailyHoroscopeModelToJson(VedicDailyHoroscopeModel data) => json.encode(data.toJson());

class VedicDailyHoroscopeModel {
  String? message;
  int? astroApiCallType;
  Map<String, List<RecordList>>? recordList;
  VedicList? vedicList;
  int? status;

  VedicDailyHoroscopeModel({
    this.message,
    this.astroApiCallType,
    this.recordList,
    this.vedicList,
    this.status,
  });

  factory VedicDailyHoroscopeModel.fromJson(Map<String, dynamic> json) => VedicDailyHoroscopeModel(
    message: json["message"],
    astroApiCallType: json["astroApiCallType"],
    recordList: Map.from(json["recordList"]!).map((k, v) => MapEntry<String, List<RecordList>>(k, List<RecordList>.from(v.map((x) => RecordList.fromJson(x))))),
    vedicList: json["vedicList"] == null ? null : VedicList.fromJson(json["vedicList"]),
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "astroApiCallType": astroApiCallType,
    "recordList": Map.from(recordList!).map((k, v) => MapEntry<String, dynamic>(k, List<dynamic>.from(v.map((x) => x.toJson())))),
    "vedicList": vedicList?.toJson(),
    "status": status,
  };
}

class RecordList {
  int? id;
  String? horoscopeType;
  String? title;
  String? description;
  int? horoscopeSignId;
  DateTime? createdAt;
  DateTime? updatedAt;

  RecordList({
    this.id,
    this.horoscopeType,
    this.title,
    this.description,
    this.horoscopeSignId,
    this.createdAt,
    this.updatedAt,
  });

  factory RecordList.fromJson(Map<String, dynamic> json) => RecordList(
    id: json["id"],
    horoscopeType: json["horoscopeType"],
    title: json["title"],
    description: json["description"],
    horoscopeSignId: json["horoscopeSignId"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "horoscopeType": horoscopeType,
    "title": title,
    "description": description,
    "horoscopeSignId": horoscopeSignId,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

class VedicList {
  List<Scope>? todayHoroscope;
  List<Scope>? weeklyHoroScope;
  List<Scope>? yearlyHoroScope;

  VedicList({
    this.todayHoroscope,
    this.weeklyHoroScope,
    this.yearlyHoroScope,
  });

  factory VedicList.fromJson(Map<String, dynamic> json) => VedicList(
    todayHoroscope: json["todayHoroscope"] == null ? [] : List<Scope>.from(json["todayHoroscope"]!.map((x) => Scope.fromJson(x))),
    weeklyHoroScope: json["weeklyHoroScope"] == null ? [] : List<Scope>.from(json["weeklyHoroScope"]!.map((x) => Scope.fromJson(x))),
    yearlyHoroScope: json["yearlyHoroScope"] == null ? [] : List<Scope>.from(json["yearlyHoroScope"]!.map((x) => Scope.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "todayHoroscope": todayHoroscope == null ? [] : List<dynamic>.from(todayHoroscope!.map((x) => x.toJson())),
    "weeklyHoroScope": weeklyHoroScope == null ? [] : List<dynamic>.from(weeklyHoroScope!.map((x) => x.toJson())),
    "yearlyHoroScope": yearlyHoroScope == null ? [] : List<dynamic>.from(yearlyHoroScope!.map((x) => x.toJson())),
  };
}

class Scope {
  int? id;
  Zodiac? zodiac;
  int? totalScore;
  String? luckyColor;
  LuckyColorCode? luckyColorCode;
  String? luckyNumber;
  int? physique;
  int? status;
  int? finances;
  int? relationship;
  int? career;
  int? travel;
  int? family;
  int? friends;
  int? health;
  String? botResponse;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? date;
  int? type;
  DateTime? startDate;
  DateTime? endDate;
  String? healthRemark;
  String? careerRemark;
  String? relationshipRemark;
  String? travelRemark;
  String? familyRemark;
  String? friendsRemark;
  String? financesRemark;
  String? statusRemark;
  ColorCode? colorCode;

  Scope({
    this.id,
    this.zodiac,
    this.totalScore,
    this.luckyColor,
    this.luckyColorCode,
    this.luckyNumber,
    this.physique,
    this.status,
    this.finances,
    this.relationship,
    this.career,
    this.travel,
    this.family,
    this.friends,
    this.health,
    this.botResponse,
    this.createdAt,
    this.updatedAt,
    this.date,
    this.type,
    this.startDate,
    this.endDate,
    this.healthRemark,
    this.careerRemark,
    this.relationshipRemark,
    this.travelRemark,
    this.familyRemark,
    this.friendsRemark,
    this.financesRemark,
    this.statusRemark,
    this.colorCode,
  });

  factory Scope.fromJson(Map<String, dynamic> json) => Scope(
    id: json["id"],
    zodiac: zodiacValues.map[json["zodiac"]]!,
    totalScore: json["total_score"],
    luckyColor: json["lucky_color"],
    luckyColorCode: luckyColorCodeValues.map[json["lucky_color_code"]]!,
    luckyNumber: json["lucky_number"],
    physique: json["physique"],
    status: json["status"],
    finances: json["finances"],
    relationship: json["relationship"],
    career: json["career"],
    travel: json["travel"],
    family: json["family"],
    friends: json["friends"],
    health: json["health"],
    botResponse: json["bot_response"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    type: json["type"],
    startDate: json["start_date"] == null ? null : DateTime.parse(json["start_date"]),
    endDate: json["end_date"] == null ? null : DateTime.parse(json["end_date"]),
    healthRemark: json["health_remark"],
    careerRemark: json["career_remark"],
    relationshipRemark: json["relationship_remark"],
    travelRemark: json["travel_remark"],
    familyRemark: json["family_remark"],
    friendsRemark: json["friends_remark"],
    financesRemark: json["finances_remark"],
    statusRemark: json["status_remark"],
    colorCode: colorCodeValues.map[json["color_code"]]!,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "zodiac": zodiacValues.reverse[zodiac],
    "total_score": totalScore,
    "lucky_color": luckyColor,
    "lucky_color_code": luckyColorCodeValues.reverse[luckyColorCode],
    "lucky_number": luckyNumber,
    "physique": physique,
    "status": status,
    "finances": finances,
    "relationship": relationship,
    "career": career,
    "travel": travel,
    "family": family,
    "friends": friends,
    "health": health,
    "bot_response": botResponse,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "date": "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
    "type": type,
    "start_date": "${startDate!.year.toString().padLeft(4, '0')}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}",
    "end_date": "${endDate!.year.toString().padLeft(4, '0')}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}",
    "health_remark": healthRemark,
    "career_remark": careerRemark,
    "relationship_remark": relationshipRemark,
    "travel_remark": travelRemark,
    "family_remark": familyRemark,
    "friends_remark": friendsRemark,
    "finances_remark": financesRemark,
    "status_remark": statusRemark,
    "color_code": colorCodeValues.reverse[colorCode],
  };
}

enum ColorCode {
  EMPTY,
  THE_0_XFF000000,
  THE_0_XFF008200
}

final colorCodeValues = EnumValues({
  "": ColorCode.EMPTY,
  "0xff000000": ColorCode.THE_0_XFF000000,
  "0xff008200": ColorCode.THE_0_XFF008200
});

enum LuckyColorCode {
  EMPTY,
  THE_000000,
  THE_008200
}

final luckyColorCodeValues = EnumValues({
  "": LuckyColorCode.EMPTY,
  "#000000": LuckyColorCode.THE_000000,
  "#008200": LuckyColorCode.THE_008200
});

enum Zodiac {
  PISCES
}

final zodiacValues = EnumValues({
  "Pisces": Zodiac.PISCES
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
