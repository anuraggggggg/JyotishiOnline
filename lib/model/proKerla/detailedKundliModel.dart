
class KundliModel {
  final String? status;
  final Data? data;

  KundliModel({this.status, this.data});

  factory KundliModel.fromJson(Map<String, dynamic> json) {
    return KundliModel(
      status: json['status'] as String?,
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
    );
  }

  static List<KundliModel> fromList(List<Map<String, dynamic>> list) {
    return list.map((json) => KundliModel.fromJson(json)).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      if (data != null) 'data': data!.toJson(),
    };
  }
}


class Data {
  NakshatraDetails? nakshatraDetails;
  MangalDosha? mangalDosha;
  List<YogaDetails>? yogaDetails;
  List<DashaPeriods>? dashaPeriods;
  DashaBalance? dashaBalance;

  Data({this.nakshatraDetails, this.mangalDosha, this.yogaDetails, this.dashaPeriods, this.dashaBalance});

  Data.fromJson(Map<String, dynamic> json) {
    nakshatraDetails = json["nakshatra_details"] == null ? null : NakshatraDetails.fromJson(json["nakshatra_details"]);
    mangalDosha = json["mangal_dosha"] == null ? null : MangalDosha.fromJson(json["mangal_dosha"]);
    yogaDetails = json["yoga_details"] == null ? null : (json["yoga_details"] as List).map((e) => YogaDetails.fromJson(e)).toList();
    dashaPeriods = json["dasha_periods"] == null ? null : (json["dasha_periods"] as List).map((e) => DashaPeriods.fromJson(e)).toList();
    dashaBalance = json["dasha_balance"] == null ? null : DashaBalance.fromJson(json["dasha_balance"]);
  }

  static List<Data> fromList(List<Map<String, dynamic>> list) {
    return list.map(Data.fromJson).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    if(nakshatraDetails != null) {
      _data["nakshatra_details"] = nakshatraDetails?.toJson();
    }
    if(mangalDosha != null) {
      _data["mangal_dosha"] = mangalDosha?.toJson();
    }
    if(yogaDetails != null) {
      _data["yoga_details"] = yogaDetails?.map((e) => e.toJson()).toList();
    }
    if(dashaPeriods != null) {
      _data["dasha_periods"] = dashaPeriods?.map((e) => e.toJson()).toList();
    }
    if(dashaBalance != null) {
      _data["dasha_balance"] = dashaBalance?.toJson();
    }
    return _data;
  }
}

class DashaBalance {
  Lord3? lord;
  String? duration;
  String? description;

  DashaBalance({this.lord, this.duration, this.description});

  DashaBalance.fromJson(Map<String, dynamic> json) {
    lord = json["lord"] == null ? null : Lord3.fromJson(json["lord"]);
    duration = json["duration"];
    description = json["description"];
  }

  static List<DashaBalance> fromList(List<Map<String, dynamic>> list) {
    return list.map(DashaBalance.fromJson).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    if(lord != null) {
      _data["lord"] = lord?.toJson();
    }
    _data["duration"] = duration;
    _data["description"] = description;
    return _data;
  }
}

class Lord3 {
  int? id;
  String? name;
  String? vedicName;

  Lord3({this.id, this.name, this.vedicName});

  Lord3.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    name = json["name"];
    vedicName = json["vedic_name"];
  }

  static List<Lord3> fromList(List<Map<String, dynamic>> list) {
    return list.map(Lord3.fromJson).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["name"] = name;
    _data["vedic_name"] = vedicName;
    return _data;
  }
}

class DashaPeriods {
  int? id;
  String? name;
  String? start;
  String? end;
  List<Antardasha>? antardasha;

  DashaPeriods({this.id, this.name, this.start, this.end, this.antardasha});

  DashaPeriods.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    name = json["name"];
    start = json["start"];
    end = json["end"];
    antardasha = json["antardasha"] == null ? null : (json["antardasha"] as List).map((e) => Antardasha.fromJson(e)).toList();
  }

  static List<DashaPeriods> fromList(List<Map<String, dynamic>> list) {
    return list.map(DashaPeriods.fromJson).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["name"] = name;
    _data["start"] = start;
    _data["end"] = end;
    if(antardasha != null) {
      _data["antardasha"] = antardasha?.map((e) => e.toJson()).toList();
    }
    return _data;
  }
}

class Antardasha {
  int? id;
  String? name;
  String? start;
  String? end;
  List<Pratyantardasha>? pratyantardasha;

  Antardasha({this.id, this.name, this.start, this.end, this.pratyantardasha});

  Antardasha.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    name = json["name"];
    start = json["start"];
    end = json["end"];
    pratyantardasha = json["pratyantardasha"] == null ? null : (json["pratyantardasha"] as List).map((e) => Pratyantardasha.fromJson(e)).toList();
  }

  static List<Antardasha> fromList(List<Map<String, dynamic>> list) {
    return list.map(Antardasha.fromJson).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["name"] = name;
    _data["start"] = start;
    _data["end"] = end;
    if(pratyantardasha != null) {
      _data["pratyantardasha"] = pratyantardasha?.map((e) => e.toJson()).toList();
    }
    return _data;
  }
}

class Pratyantardasha {
  int? id;
  String? name;
  String? start;
  String? end;

  Pratyantardasha({this.id, this.name, this.start, this.end});

  Pratyantardasha.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    name = json["name"];
    start = json["start"];
    end = json["end"];
  }

  static List<Pratyantardasha> fromList(List<Map<String, dynamic>> list) {
    return list.map(Pratyantardasha.fromJson).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["name"] = name;
    _data["start"] = start;
    _data["end"] = end;
    return _data;
  }
}

class YogaDetails {
  String? name;
  String? description;
  List<YogaList>? yogaList;

  YogaDetails({this.name, this.description, this.yogaList});

  YogaDetails.fromJson(Map<String, dynamic> json) {
    name = json["name"];
    description = json["description"];
    yogaList = json["yoga_list"] == null ? null : (json["yoga_list"] as List).map((e) => YogaList.fromJson(e)).toList();
  }

  static List<YogaDetails> fromList(List<Map<String, dynamic>> list) {
    return list.map(YogaDetails.fromJson).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["name"] = name;
    _data["description"] = description;
    if(yogaList != null) {
      _data["yoga_list"] = yogaList?.map((e) => e.toJson()).toList();
    }
    return _data;
  }
}

class YogaList {
  String? name;
  bool? hasYoga;
  String? description;

  YogaList({this.name, this.hasYoga, this.description});

  YogaList.fromJson(Map<String, dynamic> json) {
    name = json["name"];
    hasYoga = json["has_yoga"];
    description = json["description"];
  }

  static List<YogaList> fromList(List<Map<String, dynamic>> list) {
    return list.map(YogaList.fromJson).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["name"] = name;
    _data["has_yoga"] = hasYoga;
    _data["description"] = description;
    return _data;
  }
}

class MangalDosha {
  bool? hasDosha;
  String? description;
  bool? hasException;
  dynamic type;
  List<dynamic>? exceptions;
  List<dynamic>? remedies;

  MangalDosha({this.hasDosha, this.description, this.hasException, this.type, this.exceptions, this.remedies});

  MangalDosha.fromJson(Map<String, dynamic> json) {
    hasDosha = json["has_dosha"];
    description = json["description"];
    hasException = json["has_exception"];
    type = json["type"];
    exceptions = json["exceptions"] ?? [];
    remedies = json["remedies"] ?? [];
  }

  static List<MangalDosha> fromList(List<Map<String, dynamic>> list) {
    return list.map(MangalDosha.fromJson).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["has_dosha"] = hasDosha;
    _data["description"] = description;
    _data["has_exception"] = hasException;
    _data["type"] = type;
    if(exceptions != null) {
      _data["exceptions"] = exceptions;
    }
    if(remedies != null) {
      _data["remedies"] = remedies;
    }
    return _data;
  }
}

class NakshatraDetails {
  Nakshatra? nakshatra;
  ChandraRasi? chandraRasi;
  SooryaRasi? sooryaRasi;
  Zodiac? zodiac;
  AdditionalInfo? additionalInfo;

  NakshatraDetails({this.nakshatra, this.chandraRasi, this.sooryaRasi, this.zodiac, this.additionalInfo});

  NakshatraDetails.fromJson(Map<String, dynamic> json) {
    nakshatra = json["nakshatra"] == null ? null : Nakshatra.fromJson(json["nakshatra"]);
    chandraRasi = json["chandra_rasi"] == null ? null : ChandraRasi.fromJson(json["chandra_rasi"]);
    sooryaRasi = json["soorya_rasi"] == null ? null : SooryaRasi.fromJson(json["soorya_rasi"]);
    zodiac = json["zodiac"] == null ? null : Zodiac.fromJson(json["zodiac"]);
    additionalInfo = json["additional_info"] == null ? null : AdditionalInfo.fromJson(json["additional_info"]);
  }

  static List<NakshatraDetails> fromList(List<Map<String, dynamic>> list) {
    return list.map(NakshatraDetails.fromJson).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    if(nakshatra != null) {
      _data["nakshatra"] = nakshatra?.toJson();
    }
    if(chandraRasi != null) {
      _data["chandra_rasi"] = chandraRasi?.toJson();
    }
    if(sooryaRasi != null) {
      _data["soorya_rasi"] = sooryaRasi?.toJson();
    }
    if(zodiac != null) {
      _data["zodiac"] = zodiac?.toJson();
    }
    if(additionalInfo != null) {
      _data["additional_info"] = additionalInfo?.toJson();
    }
    return _data;
  }
}

class AdditionalInfo {
  String? deity;
  String? ganam;
  String? symbol;
  String? animalSign;
  String? nadi;
  String? color;
  String? bestDirection;
  String? syllables;
  String? birthStone;
  String? gender;
  String? planet;
  String? enemyYoni;

  AdditionalInfo({this.deity, this.ganam, this.symbol, this.animalSign, this.nadi, this.color, this.bestDirection, this.syllables, this.birthStone, this.gender, this.planet, this.enemyYoni});

  AdditionalInfo.fromJson(Map<String, dynamic> json) {
    deity = json["deity"];
    ganam = json["ganam"];
    symbol = json["symbol"];
    animalSign = json["animal_sign"];
    nadi = json["nadi"];
    color = json["color"];
    bestDirection = json["best_direction"];
    syllables = json["syllables"];
    birthStone = json["birth_stone"];
    gender = json["gender"];
    planet = json["planet"];
    enemyYoni = json["enemy_yoni"];
  }

  static List<AdditionalInfo> fromList(List<Map<String, dynamic>> list) {
    return list.map(AdditionalInfo.fromJson).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["deity"] = deity;
    _data["ganam"] = ganam;
    _data["symbol"] = symbol;
    _data["animal_sign"] = animalSign;
    _data["nadi"] = nadi;
    _data["color"] = color;
    _data["best_direction"] = bestDirection;
    _data["syllables"] = syllables;
    _data["birth_stone"] = birthStone;
    _data["gender"] = gender;
    _data["planet"] = planet;
    _data["enemy_yoni"] = enemyYoni;
    return _data;
  }
}

class Zodiac {
  int? id;
  String? name;

  Zodiac({this.id, this.name});

  Zodiac.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    name = json["name"];
  }

  static List<Zodiac> fromList(List<Map<String, dynamic>> list) {
    return list.map(Zodiac.fromJson).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["name"] = name;
    return _data;
  }
}

class SooryaRasi {
  int? id;
  String? name;
  Lord? lord; // FIXED here

  SooryaRasi({this.id, this.name, this.lord});

  SooryaRasi.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    name = json["name"];
    lord = json["lord"] == null ? null : Lord.fromJson(json["lord"]);
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "lord": lord?.toJson(),
    };
  }
}


class Lord2 {
  int? id;
  String? name;
  String? vedicName;

  Lord2({this.id, this.name, this.vedicName});

  Lord2.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    name = json["name"];
    vedicName = json["vedic_name"];
  }

  static List<Lord2> fromList(List<Map<String, dynamic>> list) {
    return list.map(Lord2.fromJson).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["name"] = name;
    _data["vedic_name"] = vedicName;
    return _data;
  }
}

class ChandraRasi {
  int? id;
  String? name;
  Lord? lord; // Changed from Lord1 to Lord

  ChandraRasi({this.id, this.name, this.lord});

  ChandraRasi.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    name = json["name"];
    lord = json["lord"] == null ? null : Lord.fromJson(json["lord"]);
  }

  static List<ChandraRasi> fromList(List<Map<String, dynamic>> list) {
    return list.map(ChandraRasi.fromJson).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["name"] = name;
    if(lord != null) {
      _data["lord"] = lord?.toJson();
    }
    return _data;
  }
}

// ... and similarly for SooryaRasi and DashaBalance

class Lord1 {
  int? id;
  String? name;
  String? vedicName;

  Lord1({this.id, this.name, this.vedicName});

  Lord1.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    name = json["name"];
    vedicName = json["vedic_name"];
  }

  static List<Lord1> fromList(List<Map<String, dynamic>> list) {
    return list.map(Lord1.fromJson).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["name"] = name;
    _data["vedic_name"] = vedicName;
    return _data;
  }
}

class Nakshatra {
  int? id;
  String? name;
  Lord? lord;
  int? pada;

  Nakshatra({this.id, this.name, this.lord, this.pada});

  Nakshatra.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    name = json["name"];
    lord = json["lord"] == null ? null : Lord.fromJson(json["lord"]);
    pada = json["pada"];
  }

  static List<Nakshatra> fromList(List<Map<String, dynamic>> list) {
    return list.map(Nakshatra.fromJson).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["name"] = name;
    if(lord != null) {
      _data["lord"] = lord?.toJson();
    }
    _data["pada"] = pada;
    return _data;
  }
}

class Lord {
  int? id;
  String? name;
  String? vedicName;

  Lord({this.id, this.name, this.vedicName});

  Lord.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    name = json["name"];
    vedicName = json["vedic_name"];
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "vedic_name": vedicName,
    };
  }
}

