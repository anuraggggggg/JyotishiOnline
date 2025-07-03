class InauspiciousModel {
  final List<Muhurat>? muhuratList;

  InauspiciousModel({this.muhuratList});

  factory InauspiciousModel.fromJson(Map<String, dynamic> json) {
    // Here 'json' is already the 'data' part from API response, so no need for json['data']
    if (json == null || json['muhurat'] == null) {
      return InauspiciousModel(muhuratList: []);
    }

    return InauspiciousModel(
      muhuratList: (json['muhurat'] as List)
          .map((item) => Muhurat.fromJson(item))
          .toList(),
    );
  }

}


class Muhurat {
  final int? id;
  final String? name;
  final String? type;
  final List<TimePeriod>? period;

  Muhurat({this.id, this.name, this.type, this.period});

  factory Muhurat.fromJson(Map<String, dynamic> json) {
    return Muhurat(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      period: (json['period'] as List)
          .map((e) => TimePeriod.fromJson(e))
          .toList(),
    );
  }
}


class TimePeriod {
  final String? start;
  final String? end;

  TimePeriod({this.start, this.end});

  factory TimePeriod.fromJson(Map<String, dynamic> json) {
    return TimePeriod(
      start: json['start'],
      end: json['end'],
    );
  }

  String get interval => "${start ?? 'N/A'} - ${end ?? 'N/A'}";
}
