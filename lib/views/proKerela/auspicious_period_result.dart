import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for DateFormat
import '../../apiManager/apiServices.dart';
import '../../model/proKerla/auspicious_period_model.dart'; // Ensure this path is correct

class AuspiciousPeriodResultScreen extends StatefulWidget {
  final ApiService apiService;
  final int ayanamsa;
  final double latitude;
  final double longitude;
  final DateTime datetime;
  final String language;

  const AuspiciousPeriodResultScreen({
    super.key,
    required this.apiService,
    required this.ayanamsa,
    required this.latitude,
    required this.longitude,
    required this.datetime,
    required this.language,
  });

  @override
  _AuspiciousPeriodResultScreenState createState() => _AuspiciousPeriodResultScreenState();
}

class _AuspiciousPeriodResultScreenState extends State<AuspiciousPeriodResultScreen> {
  late Future<AuspiciousPeriodModel> _auspiciousPeriodsFuture;

  // Define a consistent sophisticated color palette
  static const Color cosmicBlue = Color(0xFF1A2B42); // Deep, dark blue
  static const Color celestialGold = Color(0xFFD4AF37); // Rich gold
  static const Color stardustWhite = Color(0xFFF0F0F0); // Off-white for readability
  static const Color lunarSilver = Color(0xFFC0C0C0); // Soft silver
  static const Color fortunateGreen = Color(0xFF28A745); // A pleasant green for positive indications

  @override
  void initState() {
    super.initState();
    _auspiciousPeriodsFuture = widget.apiService.fetchAuspiciousPeriods(
      ayanamsa: widget.ayanamsa,
      latitude: widget.latitude,
      longitude: widget.longitude,
      datetime: widget.datetime,
      language: widget.language,
    );
  }

  // MODIFIED: _formatTimeOnly now accepts nullable DateTime?
  String _formatTimeOnly(DateTime? dt) {
    if (dt == null) {
      return "N/A"; // Return "N/A" if DateTime is null
    }
    return DateFormat('hh:mm a').format(dt); // Format to 12-hour with AM/PM
  }

  // MODIFIED: _buildPeriodDetailCard now accepts List<Period> periods
  Widget _buildPeriodDetailCard(String title, IconData icon, List<Period> periods) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // More rounded corners
        side: BorderSide(color: celestialGold.withOpacity(0.6), width: 1.5), // Subtle gold border
      ),
      elevation: 8, // Increased elevation for a lifted look
      margin: const EdgeInsets.symmetric(vertical: 12), // Adjusted vertical margin
      color: cosmicBlue.withOpacity(0.8), // Semi-transparent dark blue card background
      child: Padding(
        padding: const EdgeInsets.all(20), // Increased internal padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: celestialGold, size: 30), // Gold icon, slightly larger
                const SizedBox(width: 12), // More space
                Expanded( // Use Expanded to prevent overflow for long titles
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700, // Bolder title
                      fontSize: 20, // Larger title
                      color: celestialGold, // Gold title
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(color: lunarSilver, height: 25, thickness: 0.5), // Subtle divider
            if (periods.isEmpty)
              const Text(
                'No specific timings for this period.',
                style: TextStyle(color: stardustWhite, fontSize: 16),
              )
            else
              ...periods.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.access_time, color: lunarSilver, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        // Access p.start and p.end directly, as _formatTimeOnly handles nulls
                        '${_formatTimeOnly(p.start)} - ${_formatTimeOnly(p.end)}',
                        style: const TextStyle(
                          color: stardustWhite,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Auspicious Timing Insights', // More thematic title
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: stardustWhite,
            fontSize: 22,
            letterSpacing: 1.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: cosmicBlue, // Dark app bar
        elevation: 0, // No shadow
        iconTheme: const IconThemeData(color: stardustWhite), // Back arrow color
      ),
      body: Container(
        // Ensure the container fills available space
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
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
        child: FutureBuilder<AuspiciousPeriodModel>(
          future: _auspiciousPeriodsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: celestialGold, strokeWidth: 4),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent, size: 60),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load auspicious periods: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: stardustWhite, fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Allow retry
                          setState(() {
                            _auspiciousPeriodsFuture = widget.apiService.fetchAuspiciousPeriods(
                              ayanamsa: widget.ayanamsa,
                              latitude: widget.latitude,
                              longitude: widget.longitude,
                              datetime: widget.datetime,
                              language: widget.language,
                            );
                          });
                        },
                        icon: const Icon(Icons.refresh, color: cosmicBlue),
                        label: const Text(
                          'Retry',
                          style: TextStyle(color: cosmicBlue, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(backgroundColor: celestialGold),
                      ),
                    ],
                  ),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.periods.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.info_outline, color: lunarSilver, size: 60),
                      const SizedBox(height: 16),
                      const Text(
                        'No auspicious periods found for the given details. Try adjusting the date/time or location.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: stardustWhite, fontSize: 18),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(25), // Increased overall padding
              itemCount: snapshot.data!.periods.length,
              itemBuilder: (context, index) {
                final period = snapshot.data!.periods[index];
                IconData periodIcon;
                // Assign an icon based on the period name (you can expand this)
                switch (period.name.toLowerCase()) {
                  case 'brahma muhurta':
                    periodIcon = Icons.self_improvement; // Yoga/meditation related
                    break;
                  case 'abhijit muhurta':
                    periodIcon = Icons.military_tech; // Victory/auspicious start
                    break;
                  case 'hora':
                    periodIcon = Icons.hourglass_empty; // Time related
                    break;
                  case 'choghadiya':
                    periodIcon = Icons.event_note; // Event related
                    break;
                  case 'disha shool':
                    periodIcon = Icons.block; // Directional obstacle
                    break;
                  case 'rahukalam':
                    periodIcon = Icons.cloud_off; // Inauspicious shadow
                    break;
                  case 'yamaganda':
                    periodIcon = Icons.dangerous; // Inauspicious
                    break;
                  case 'gulika kalam':
                    periodIcon = Icons.filter_drama; // Inauspicious
                    break;
                  default:
                    periodIcon = Icons.access_time; // Generic time icon
                }

                // Pass period.periods which is List<Period> to _buildPeriodDetailCard
                return _buildPeriodDetailCard(
                  period.name,
                  periodIcon,
                  period.periods, // This is the correct list of Period objects
                );
              },
            );
          },
        ),
      ),
    );
  }
}