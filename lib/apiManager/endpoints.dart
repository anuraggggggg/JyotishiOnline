class ApiEndpoints {
  static const String baseAstrologyUrl  = 'https://api.prokerala.com/v2/astrology';
  static const String baseHoroscopeUrl = 'https://api.prokerala.com/v2/horoscope';
  static const String baseNumerologyUrl = 'https://api.prokerala.com/v2/numerology';

  // Astrology endpoints
  static const String panchang            = '$baseAstrologyUrl/panchang/advanced';
  static const String inauspiciousPeriods = '$baseAstrologyUrl/inauspicious-period';
  static const String auspiciousPeriods   = '$baseAstrologyUrl/auspicious-period';
  static const String detailedKundli      = '$baseAstrologyUrl/kundli/advanced';
  static const String planetPosition      = '$baseAstrologyUrl/planet-position';

  // Horoscope endpoints
  static const String dailyHoroscope      = '$baseHoroscopeUrl/daily';
  static const String loveCompatibility   = '$baseHoroscopeUrl/daily/love-compatibility';

  // Numerology endpoints
  static const String birthdayNumber      = '$baseNumerologyUrl/birthday-number';
}
