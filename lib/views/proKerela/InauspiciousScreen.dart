import 'package:flutter/material.dart';
import '../../model/proKerla/InauspiciousModel.dart' show InauspiciousModel;

class InauspiciousScreen extends StatelessWidget {
  final InauspiciousModel inauspiciousData;

  const InauspiciousScreen({super.key, required this.inauspiciousData});

  // Define a consistent sophisticated color palette from the input screen
  static const Color cosmicBlue = Color(0xFF1A2B42); // Deep, dark blue
  static const Color celestialGold = Color(0xFFD4AF37); // Rich gold
  static const Color stardustWhite = Color(0xFFF0F0F0); // Off-white for readability
  static const Color smokyGrey = Color(0xFF4A4A4A); // For input field hints/labels
  static const Color lunarSilver = Color(0xFFC0C0C0); // Soft silver
  static const Color darkAccent = Color(0xFF2C3E50); // For darker gradient part
  static const Color mediumAccent = Color(0xFF34495E); // For medium gradient part

  // Specific warning color for inauspicious periods, aligned with the gold/orange spectrum
  static const Color warningAstrology = Color(0xFFDAA520); // Goldenrod for warnings

  // Helper function to format time string (e.g., "13:30" -> "1:30 PM")
  String _formatTime(String time) {
    try {
      final parts = time.split(':');
      if (parts.length != 2) return time; // Return original if format is unexpected

      int hour = int.tryParse(parts[0]) ?? 0;
      final minute = parts[1];

      String period = 'AM';
      if (hour >= 12) {
        period = 'PM';
        if (hour > 12) hour -= 12;
      }
      if (hour == 0) hour = 12; // Handle midnight

      return '$hour:$minute $period';
    } catch (e) {
      return time; // Fallback to original if parsing fails
    }
  }

  // Helper function to format interval (e.g., "13:30-15:45" -> "1:30 PM - 3:45 PM")
  String _formatInterval(String interval) {
    final parts = interval.split('-');
    if (parts.length == 2) {
      return '${_formatTime(parts[0].trim())} - ${_formatTime(parts[1].trim())}';
    }
    return interval; // Return original if format is unexpected
  }

  @override
  Widget build(BuildContext context) {
    final muhuratList = inauspiciousData.muhuratList ?? [];
    // The theme is not directly used for colors as we have a custom palette,
    // but it's good practice to keep it for other theme-related properties if needed.
    // final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true, // Allow body to go behind app bar for gradient effect
      appBar: AppBar(
        title: const Text(
          'Inauspicious Periods',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: stardustWhite,
            fontSize: 22,
            letterSpacing: 1.2, // Consistent letter spacing
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Make app bar transparent
        elevation: 0,
        iconTheme: const IconThemeData(color: stardustWhite, size: 28), // Larger back icon
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cosmicBlue,
              darkAccent,
              mediumAccent,
            ],
            stops: [0.1, 0.5, 0.9], // Fine-tune gradient stops for depth
          ),
        ),
        child: muhuratList.isEmpty
            ? Center(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.brightness_low_rounded, // Thematic empty icon
                  size: 72, // Larger icon
                  color: lunarSilver.withOpacity(0.6),
                ),
                const SizedBox(height: 24),
                Text(
                  'No significant inauspicious periods found for this date.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: stardustWhite.withOpacity(0.8),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'The cosmic energies appear favorable.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: lunarSilver.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context), // Go back to input screen
                  icon: const Icon(Icons.arrow_back, color: cosmicBlue),
                  label: const Text(
                    'Go Back',
                    style: TextStyle(color: cosmicBlue, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: celestialGold,
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                  ),
                ),
              ],
            ),
          ),
        )
            : ListView.separated(
          padding: const EdgeInsets.all(25).copyWith(top: AppBar().preferredSize.height + 25), // Adjust padding for transparent app bar
          itemCount: muhuratList.length,
          separatorBuilder: (context, index) => const SizedBox(height: 20), // More space between cards
          itemBuilder: (context, index) {
            final muhurat = muhuratList[index];
            return Card(
              elevation: 10, // Consistent elevation with input screen cards
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25), // Consistent border radius
                side: BorderSide(color: celestialGold.withOpacity(0.7), width: 1.5), // Consistent border
              ),
              color: cosmicBlue.withOpacity(0.85), // Consistent card background color
              child: Padding(
                padding: const EdgeInsets.all(30), // Consistent padding inside card
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.sentiment_dissatisfied_rounded, // More expressive "inauspicious" icon
                          color: warningAstrology,
                          size: 32, // Larger icon
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            muhurat.name ?? 'Unnamed Cosmic Influence', // More thematic default text
                            style: TextStyle(
                              fontSize: 24, // Larger title
                              fontWeight: FontWeight.bold,
                              color: warningAstrology,
                              letterSpacing: 0.8, // Subtle letter spacing
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 3,
                                  offset: const Offset(1, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (muhurat.type != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Type: ${muhurat.type!}', // Label "Type" for clarity
                        style: TextStyle(
                          fontSize: 18, // Consistent font size
                          fontStyle: FontStyle.italic,
                          color: lunarSilver,
                        ),
                      ),
                    ],
                    if (muhurat.period?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 25), // Increased spacing
                      Text(
                        'Periods of Caution:', // More thematic heading
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: stardustWhite.withOpacity(0.9),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...muhurat.period!.map((period) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8), // More vertical padding
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 4), // Align icon with text
                                child: Icon(
                                  Icons.access_time_filled_rounded, // Filled time icon for emphasis
                                  size: 22, // Slightly larger icon
                                  color: celestialGold.withOpacity(0.9), // Gold accent
                                ),
                              ),
                              const SizedBox(width: 12), // More spacing
                              Expanded(
                                child: Text(
                                  _formatInterval(period.interval),
                                  style: const TextStyle(
                                    fontSize: 18, // Consistent font size
                                    color: stardustWhite,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}