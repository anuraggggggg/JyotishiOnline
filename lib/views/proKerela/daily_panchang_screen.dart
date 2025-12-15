import 'package:AstrowayCustomer/apiManager/apiServices.dart';
import 'package:AstrowayCustomer/views/proKerela/auspicious_period_input.dart';
import 'package:AstrowayCustomer/views/proKerela/panchang_input_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/appTheme.dart'; // Assuming appTheme.dart provides appYellow and buttonColor2
import 'inauspiciousInputPeriod.dart';

class DailyPanchangScreen extends StatelessWidget {
  final serviceName ;
  final servicePrice;

  DailyPanchangScreen({super.key ,  required this.servicePrice ,  required this.serviceName});

  final List<Map<String, dynamic>> panchangServices = [
    {'title': 'Detailed Panchang', 'icon': Icons.event_note},
    // {'title': 'Auspicious Period', 'icon': Icons.check_circle},
    // {'title': 'Inauspicious Period', 'icon': Icons.cancel},
    // {'title': 'Choghadiya', 'icon': Icons.access_time},
    // {'title': 'Hindu Panchang', 'icon': Icons.menu_book},
    // {'title': 'Tamil Panchang', 'icon': Icons.language},
    // {'title': 'Telugu Panchang', 'icon': Icons.translate},
    // {'title': 'Malayalam Panchang', 'icon': Icons.book},
    // {'title': 'Calendar', 'icon': Icons.calendar_today},
    // {'title': 'Anandadi Yoga', 'icon': Icons.self_improvement},
    // {'title': 'Chandra Bala', 'icon': Icons.nightlight_round},
    // {'title': 'Tara Bala', 'icon': Icons.stars},
    // {'title': 'Ritu', 'icon': Icons.filter_hdr},
    // {'title': 'Solstice', 'icon': Icons.wb_sunny},
    // {'title': 'Hora', 'icon': Icons.timelapse},
    // {'title': 'Disha Shool', 'icon': Icons.explore},
    // {'title': 'Auspicious Yoga', 'icon': Icons.star},
  ];

  @override
  Widget build(BuildContext context) {
    // Define a consistent sophisticated color palette
    const Color cosmicBlue = Color(0xFF1A2B42); // Deep, dark blue
    const Color celestialGold = Color(0xFFD4AF37); // Rich gold
    const Color stardustWhite = Color(0xFFF0F0F0); // Off-white for readability

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daily Panchang',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: stardustWhite,
            fontSize: 22,
            letterSpacing: 1.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: cosmicBlue,
        elevation: 0,
        iconTheme:
            const IconThemeData(color: stardustWhite), // Back arrow color
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cosmicBlue,
              Color(0xFF2C3E50), // A slightly lighter dark blue
              Color(0xFF34495E), // Another shade
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: 20, horizontal: 25), // Increased horizontal padding
          child: ListView.builder(
            itemCount: panchangServices.length,
            itemBuilder: (context, index) {
              final service = panchangServices[index];
              return Column(
                children: [
                  _buildServiceCard(
                    context,
                    title: service['title'],
                    icon: service['icon'],
                    onTap: () {
                      if (service['title'] == 'Detailed Panchang') {
                        Get.to(() => PanchangInputScreen());
                      } else if (service['title'] == 'Inauspicious Period') {
                        Get.to(() => InauspiciousInputScreen());
                      } else if (service["title"] == "Auspicious Period") {
                        Get.to(() => AuspiciousPeriodInputScreen(
                              apiService: ApiService(),
                            ));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  '"${service['title']}" is coming soon!')),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 18), // Adjusted spacing between cards
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    // Define a consistent sophisticated color palette within the function too
    const Color cosmicBlue = Color(0xFF1A2B42);
    const Color celestialGold = Color(0xFFD4AF37);
    const Color stardustWhite = Color(0xFFF0F0F0);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 8, // Added elevation for a lifted look
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // More rounded corners
          side: BorderSide(
              color: celestialGold.withOpacity(0.6),
              width: 1.5), // Subtle gold border
        ),
        color:
            cosmicBlue.withOpacity(0.8), // Slightly transparent dark blue card
        child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: 20, horizontal: 20), // Increased padding
          child: Row(
            children: [
              Icon(icon, size: 38, color: celestialGold), // Larger gold icon
              const SizedBox(width: 20), // More spacing
              Expanded(
                // Use Expanded to prevent text overflow
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20, // Larger font size
                    fontWeight: FontWeight.w700, // Bolder text
                    color: stardustWhite, // White text for contrast
                    letterSpacing: 0.5, // Subtle letter spacing
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
