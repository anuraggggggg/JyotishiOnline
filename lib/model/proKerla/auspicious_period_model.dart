class AuspiciousPeriodModel {
  final List<AuspiciousPeriod> periods;

  AuspiciousPeriodModel({required this.periods});

  factory AuspiciousPeriodModel.fromJson(Map<String, dynamic> json) {
    final periods = (json['muhurat'] as List)
        .map((periodJson) => AuspiciousPeriod.fromJson(periodJson))
        .toList();
    return AuspiciousPeriodModel(periods: periods);
  }
}

class AuspiciousPeriod {
  final int id;
  final String name;
  final String type;
  final List<Period> periods;

  AuspiciousPeriod({
    required this.id,
    required this.name,
    required this.type,
    required this.periods,
  });

  factory AuspiciousPeriod.fromJson(Map<String, dynamic> json) {
    return AuspiciousPeriod(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      periods: (json['period'] as List)
          .map((periodJson) => Period.fromJson(periodJson))
          .toList(),
    );
  }
}

class InauspiciousPeriodModel {
  final List<InauspiciousPeriod> periods;

  InauspiciousPeriodModel({required this.periods});

  factory InauspiciousPeriodModel.fromJson(Map<String, dynamic> json) {
    final periods = (json['inauspicious'] as List)
        .map((periodJson) => InauspiciousPeriod.fromJson(periodJson))
        .toList();
    return InauspiciousPeriodModel(periods: periods);
  }
}

class InauspiciousPeriod {
  final int id;
  final String name;
  final String type;
  final List<Period> periods;

  InauspiciousPeriod({
    required this.id,
    required this.name,
    required this.type,
    required this.periods,
  });

  factory InauspiciousPeriod.fromJson(Map<String, dynamic> json) {
    return InauspiciousPeriod(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      periods: (json['period'] as List)
          .map((periodJson) => Period.fromJson(periodJson))
          .toList(),
    );
  }
}

class Period {
  final DateTime start;
  final DateTime end;

  Period({
    required this.start,
    required this.end,
  });

  factory Period.fromJson(Map<String, dynamic> json) {
    return Period(
      start: DateTime.parse(json['start']),
      end: DateTime.parse(json['end']),
    );
  }
}