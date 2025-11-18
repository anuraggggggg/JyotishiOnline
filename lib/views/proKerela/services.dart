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
      'title': 'Daily\nHoroscope',
      'icon': Icons.calendar_month,
      'price': 100,
    },
    {
      'title': 'Detailed\nKundli',
      'icon': Icons.auto_stories,
      'price': 599,
    },
    {
      'title': 'Daily\nPrediction',
      'icon': Icons.wb_sunny,
      'price': 100,
    },
    {
      'title': 'Planet\nPosition',
      'icon': Icons.star_outline,
      'price': 599,
    },
    {
      'title': 'Love\nCompatibility',
      'icon': Icons.favorite_rounded,
      'price': 599,
    },
    {
      'title': 'Birthday\nNumber',
      'icon': Icons.numbers,
      'price': 100,
    },
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
        ).tr(),
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
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, index) {
              final service = services[index];
              final String title = service['title'] as String;

              return GestureDetector(
                onTap: () {
                  if (title == 'Daily\nPrediction') {
                    Get.to(() => DailyPanchangScreen());
                  } else if (title == 'Detailed\nKundli') {
                    Get.to(() => KundliInputScreen());
                  } else if (title == 'Daily\nHoroscope') {
                    Get.to(() => DailyPredictionInputScreen());
                  } else if (title == 'Planet\nPosition') {
                    Get.to(() => PlanetInputScreen());
                  } else if (title == 'Love\nCompatibility') {
                    Get.to(() => LoveCompatibilityInputScreen());
                  } else if (title == 'Birthday\nNumber') {
                    Get.to(() => BirthdayNumberInputScreen());
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
                      children: [
                        Icon(
                          service['icon'],
                          size: 50,
                          color: celestialGold,
                        ),
                        const SizedBox(height: 12),

                        // 🔥 Title: keeps original key (with \n) but avoids overflow
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: stardustWhite,
                                letterSpacing: 0.5,
                              ),
                            ).tr(),
                          ),
                        ),

                        const SizedBox(height: 12),

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
                                width: 0.8,
                              ),
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
