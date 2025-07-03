class DetailedPanchangModel {
  final String vaara;
  final String sunrise;
  final String sunset;
  final String moonrise;
  final String moonset;
  final List<Nakshatra> nakshatra;
  final List<Tithi> tithi;
  final List<Karana> karana;
  final List<Yoga> yoga;
  final List<Muhurta> auspiciousPeriod;
  final List<Muhurta> inauspiciousPeriod;

  DetailedPanchangModel({
    required this.vaara,
    required this.sunrise,
    required this.sunset,
    required this.moonrise,
    required this.moonset,
    required this.nakshatra,
    required this.tithi,
    required this.karana,
    required this.yoga,
    required this.auspiciousPeriod,
    required this.inauspiciousPeriod,
  });

  factory DetailedPanchangModel.fromJson(Map<String, dynamic> json) {
    // It's crucial that the 'json' map passed to this factory
    // IS THE 'data' object itself from the API response, NOT the full response.
    // So, if your full response is { "status": "ok", "data": { ... } },
    // you should call DetailedPanchangModel.fromJson(response['data']).
    // If you intend to pass the *full* response here, uncomment and use the line below:
    // final Map<String, dynamic> data = json['data'] as Map<String, dynamic>? ?? {};

    // Assuming 'json' IS the 'data' object from the API response
    // Add null-aware operators and default values for robustness
    // This makes the parsing more resilient if fields might be missing or null in the 'data' payload itself.
    return DetailedPanchangModel(
      vaara: json['vaara'] as String? ??
          'N/A', // Provide a default if vaara is null
      sunrise: json['sunrise'] as String? ?? 'N/A',
      sunset: json['sunset'] as String? ?? 'N/A',
      moonrise: json['moonrise'] as String? ?? 'N/A',
      moonset: json['moonset'] as String? ?? 'N/A',
      nakshatra: (json['nakshatra'] as List<dynamic>?)
              ?.map((e) => Nakshatra.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [], // Default to empty list if null
      tithi: (json['tithi'] as List<dynamic>?)
              ?.map((e) => Tithi.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      karana: (json['karana'] as List<dynamic>?)
              ?.map((e) => Karana.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      yoga: (json['yoga'] as List<dynamic>?)
              ?.map((e) => Yoga.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      auspiciousPeriod: (json['auspicious_period'] as List<dynamic>?)
              ?.map((e) => Muhurta.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      inauspiciousPeriod: (json['inauspicious_period'] as List<dynamic>?)
              ?.map((e) => Muhurta.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class Nakshatra {
  final int id;
  final String name;
  final String start;
  final String end;
  final NakshatraLord lord;

  Nakshatra({
    required this.id,
    required this.name,
    required this.start,
    required this.end,
    required this.lord,
  });

  factory Nakshatra.fromJson(Map<String, dynamic> json) {
    return Nakshatra(
      id: json['id'] as int? ?? 0, // Default for int
      name: json['name'] as String? ?? 'N/A',
      start: json['start'] as String? ?? 'N/A',
      end: json['end'] as String? ?? 'N/A',
      // Ensure 'lord' is not null before passing to fromJson, provide a default if needed
      lord: NakshatraLord.fromJson(json['lord'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class NakshatraLord {
  final int id;
  final String name;
  final String vedicName;

  NakshatraLord({
    required this.id,
    required this.name,
    required this.vedicName,
  });

  factory NakshatraLord.fromJson(Map<String, dynamic> json) {
    return NakshatraLord(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'N/A',
      vedicName: json['vedic_name'] as String? ?? 'N/A',
    );
  }
}

class Muhurta {
  final int id;
  final String name;
  final String type; // "Auspicious" or "Inauspicious"
  final List<MuhurtaPeriod> period;

  Muhurta({
    required this.id,
    required this.name,
    required this.type,
    required this.period,
  });

  factory Muhurta.fromJson(Map<String, dynamic> json) {
    return Muhurta(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'N/A',
      type: json['type'] as String? ?? 'N/A',
      period: (json['period'] as List<dynamic>?)
              ?.map((e) => MuhurtaPeriod.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class MuhurtaPeriod {
  final String start;
  final String end;

  MuhurtaPeriod({required this.start, required this.end});

  factory MuhurtaPeriod.fromJson(Map<String, dynamic> json) {
    return MuhurtaPeriod(
      start: json['start'] as String? ?? 'N/A',
      end: json['end'] as String? ?? 'N/A',
    );
  }
}

class Tithi {
  final int id;
  final int index;
  final String name;
  final String paksha;
  final String start;
  final String end;

  Tithi({
    required this.id,
    required this.index,
    required this.name,
    required this.paksha,
    required this.start,
    required this.end,
  });

  factory Tithi.fromJson(Map<String, dynamic> json) {
    return Tithi(
      id: json['id'] as int? ?? 0,
      index: json['index'] as int? ?? 0,
      name: json['name'] as String? ?? 'N/A',
      paksha: json['paksha'] as String? ?? 'N/A',
      start: json['start'] as String? ?? 'N/A',
      end: json['end'] as String? ?? 'N/A',
    );
  }
}

class Karana {
  final int id;
  final int index;
  final String name;
  final String start;
  final String end;

  Karana({
    required this.id,
    required this.index,
    required this.name,
    required this.start,
    required this.end,
  });

  factory Karana.fromJson(Map<String, dynamic> json) {
    return Karana(
      id: json['id'] as int? ?? 0,
      index: json['index'] as int? ?? 0,
      name: json['name'] as String? ?? 'N/A',
      start: json['start'] as String? ?? 'N/A',
      end: json['end'] as String? ?? 'N/A',
    );
  }
}

class Yoga {
  final int id;
  final String name;
  final String start;
  final String end;

  Yoga({
    required this.id,
    required this.name,
    required this.start,
    required this.end,
  });

  factory Yoga.fromJson(Map<String, dynamic> json) {
    return Yoga(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'N/A',
      start: json['start'] as String? ?? 'N/A',
      end: json['end'] as String? ?? 'N/A',
    );
  }
}
