import 'package:AstrowayCustomer/views/proKerela/birthdayNumberInputScreen.dart';
import 'package:AstrowayCustomer/views/proKerela/dailyPredictionInputScreen.dart';
import 'package:AstrowayCustomer/views/proKerela/kundli_input_screen.dart';
import 'package:AstrowayCustomer/views/proKerela/planetInputScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../theme/appTheme.dart';
import 'LoveCompatibilityInputScreen.dart';
import 'daily_panchang_screen.dart';
import 'numerology_and_horoscope_screen.dart.dart';
import 'package:google_fonts/google_fonts.dart';

class AstrologyServicesPage extends StatelessWidget {
  final List<Map<String, dynamic>> services = [
    {
      'title': 'Daily Panchang',
      'icon': Icons.wb_sunny,
      "subtitletitleinMalayam": "ദൈനംദിന പഞ്ചാംഗം",
      'price': 100,
    },
    {
      'title': 'Detailed Kundli',
      'icon': Icons.auto_stories,
      "subtitletitleinMalayam": "വിശദമായ കുണ്ഡലി",
      'price': 599,
    },
    {
      "title": "Daily Horoscope",
      "icon": Icons.calendar_month,
      "subtitletitleinMalayam": "ദൈനംദിന ജാതകം",
      'price': 100,
    },
    {
      "title": "Planet Position",
      "icon": Icons.star_outline,
      "subtitletitleinMalayam": "ഗ്രഹങ്ങളുടെ സ്ഥാനം",
      'price': 599,
    },
    {
      "title": "Love Compatibility",
      "icon": Icons.favorite_rounded,
      "subtitletitleinMalayam": "പ്രണയ അനുയോജ്യത",
      'price': 599,
    },
    {
      "title": "Numerology",
      "icon": Icons.numbers,
      "subtitletitleinMalayam": "സംഖ്യാശാസ്ത്രം",
      'price': 100,
    }
  ];

  @override
  Widget build(BuildContext context) {
    const Color cosmicBlue = Color(0xFF1A2B42);
    const Color celestialGold = Color(0xFFD4AF37);
    const Color lunarSilver = Color(0xFFC0C0C0);
    const Color stardustWhite = Color(0xFFF0F0F0);
    const Color darkAccent = Color(0xFF2C3E50);
    const Color mediumAccent = Color(0xFF34495E);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Cosmic Insights',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: stardustWhite,
            fontSize: 24,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: cosmicBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: stardustWhite, size: 28),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cosmicBlue,
              darkAccent,
              mediumAccent,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: GridView.builder(
            itemCount: services.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 25,
              crossAxisSpacing: 25,
              // *** KEY CHANGE HERE: Make cards taller to prevent overflow ***
              childAspectRatio:
                  0.75, // Decreased from 0.85 to give more vertical space
            ),
            itemBuilder: (context, index) {
              final service = services[index];
              return GestureDetector(
                onTap: () {
                  if (service['title'] == 'Daily Panchang') {
                    Get.to(() => DailyPanchangScreen());
                  } else if (service['title'] == 'Detailed Kundli') {
                    Get.to(() => KundliInputScreen());
                  } else if (service['title'] == 'Daily Horoscope') {
                    Get.to(() => DailyPredictionInputScreen());
                  } else if (service['title'] == "Planet Position") {
                    Get.to(() => PlanetInputScreen());
                  } else if (service['title'] == "Love Compatibility") {
                    Get.to(() => LoveCompatibilityInputScreen());
                  } else if (service["title"] == "Numerology") {
                    Get.to(() => BirthdayNumberInputScreen());
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('"${service['title']}" is coming soon!')),
                    );
                  }
                },
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  color: cosmicBlue.withOpacity(0.7),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: celestialGold.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      // You can also add `crossAxisAlignment: CrossAxisAlignment.stretch` if you want content to fill horizontally more
                      children: [
                        Icon(
                          service['icon'],
                          size:
                              50, // Slightly reduced icon size for more breathing room
                          color: celestialGold,
                        ),
                        const SizedBox(height: 12), // Adjusted spacing
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            service['title'].toString(),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize:
                                  15, // Slightly reduced font size for main title
                              fontWeight: FontWeight.w800,
                              color: stardustWhite,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        if (service['subtitletitleinMalayam'] != null)
                          Column(
                            children: [
                              const SizedBox(height: 3), // Adjusted spacing
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  service['subtitletitleinMalayam'].toString(),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize:
                                        11, // Slightly reduced font size for subtitle
                                    fontWeight: FontWeight.w500,
                                    color: lunarSilver,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 12), // Spacing before price
                        if (service['price'] != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            margin: const EdgeInsets.symmetric(horizontal: 15),
                            decoration: BoxDecoration(
                              color: celestialGold.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: celestialGold.withOpacity(0.4),
                                  width: 0.8),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '₹${service['price'].toString()}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: celestialGold,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                Text(
                                  '+ GST',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: lunarSilver,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
