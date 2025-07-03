class PlanetPositionModel {
  final List<PlanetPosition> planetPositions;

  PlanetPositionModel({required this.planetPositions});

  factory PlanetPositionModel.fromJson(Map<String, dynamic> json) {
    final list = json['planet_position'] as List<dynamic>? ?? [];

    final positions = list.map((e) => PlanetPosition.fromJson(e)).toList();

    return PlanetPositionModel(planetPositions: positions);
  }

}

class PlanetPosition {
  final int id;
  final String name;
  final double longitude;
  final bool isRetrograde;
  final int position;
  final double degree;
  final Rasi rasi;

  PlanetPosition({
    required this.id,
    required this.name,
    required this.longitude,
    required this.isRetrograde,
    required this.position,
    required this.degree,
    required this.rasi,
  });

  factory PlanetPosition.fromJson(Map<String, dynamic> json) {
    return PlanetPosition(
      id: json['id'],
      name: json['name'],
      longitude: (json['longitude'] as num).toDouble(),
      isRetrograde: json['is_retrograde'],
      position: json['position'],
      degree: (json['degree'] as num).toDouble(),
      rasi: Rasi.fromJson(json['rasi']),
    );
  }
}

class Rasi {
  final int id;
  final String name;
  final Lord lord;

  Rasi({
    required this.id,
    required this.name,
    required this.lord,
  });

  factory Rasi.fromJson(Map<String, dynamic> json) {
    return Rasi(
      id: json['id'],
      name: json['name'],
      lord: Lord.fromJson(json['lord']),
    );
  }
}

class Lord {
  final int id;
  final String name;
  final String vedicName;

  Lord({
    required this.id,
    required this.name,
    required this.vedicName,
  });

  factory Lord.fromJson(Map<String, dynamic> json) {
    return Lord(
      id: json['id'],
      name: json['name'],
      vedicName: json['vedic_name'],
    );
  }
}
