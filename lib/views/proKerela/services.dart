import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';

// Models & Provider
import '../../controllers/fastApiProvider/cosmic_services_provider.dart';


// Screens
import 'package:AstrowayCustomer/views/proKerela/dailyPredictionInputScreen.dart';
import 'package:AstrowayCustomer/views/proKerela/birthdayNumberInputScreen.dart';
import 'package:AstrowayCustomer/views/proKerela/kundli_input_screen.dart';
import 'package:AstrowayCustomer/views/proKerela/planetInputScreen.dart';
import '../../model/fastApiModel/cosmic_service_model.dart';
import 'LoveCompatibilityInputScreen.dart';
import 'daily_panchang_screen.dart';

class AstrologyServicesPage extends StatelessWidget {
  const AstrologyServicesPage({super.key});

  // ICON MAPPER
  IconData getIcon(String name) {
    switch (name.toLowerCase()) {
      case "calendar":
        return Icons.calendar_month;
      case "book":
        return Icons.auto_stories;
      case "sun":
        return Icons.wb_sunny;
      case "star":
        return Icons.star_outline;
      case "heart":
        return Icons.favorite_rounded;
      case "hashtag":
        return Icons.numbers;
      default:
        return Icons.help_outline;
    }
  }

  // ✅ NAVIGATION USING MODEL (CORRECT)
  Widget navigateTo(CosmicService service) {


    if (service.name == "Daily Horoscope") {
      return DailyPredictionInputScreen(
        serviceName: service.name,
        servicePrice: service.finalPrice.toDouble(),

      );
    }


    if (service.name == "Detailed Kundli") {
      return KundliInputScreen(
        serviceName : service.name,
        servicePrice : service.finalPrice.toDouble(),
      );
    }

    if (service.name == "Daily Prediction") {
      return DailyPanchangScreen(
        serviceName : service.name,
        servicePrice : service.finalPrice.toDouble(),
      );
    }

    if (service.name == "Planet Position") {
      return PlanetInputScreen(
        serviceName : service.name,
        servicePrice : service.finalPrice.toDouble(),
      );
    }

    if (service.name == "Love Compatibility") {
      return LoveCompatibilityInputScreen(
        serviceName : service.name,
        servicePrice : service.finalPrice.toDouble(),
      );
    }

    if (service.name == "Birthday Number") {
      return BirthdayNumberInputScreen(
        serviceName : service.name,
        servicePrice : service.finalPrice.toDouble(),
      );
    }

    // fallback (safe)
    return DailyPredictionInputScreen(
      serviceName: service.name,
      servicePrice: service.finalPrice.toDouble(),
    );
  }

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
          ),
        ).tr(),
        backgroundColor: cosmicBlue,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [cosmicBlue, darkAccent, mediumAccent],
          ),
        ),
        child: Consumer<CosmicServicesProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            final List<CosmicService> services = provider.services;

            return Padding(
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
                  final CosmicService service = services[index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => navigateTo(service),
                        ),
                      );
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
                              getIcon(service.icon),
                              size: 50,
                              color: celestialGold,
                            ),
                            const SizedBox(height: 12),

                            // SERVICE NAME
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 8.0),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  service.name,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: stardustWhite,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // PRICE (FINAL PRICE)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
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
                                    "₹${service.price}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: celestialGold,
                                    ),
                                  ),
                                  Text(
                                    "GST ${service.gst}" ,
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
            );
          },
        ),
      ),
    );
  }
}
