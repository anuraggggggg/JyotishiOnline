import 'dart:io';
import 'dart:typed_data'; // For font loading
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle; // For font loading
import 'package:get/get.dart';
import '../../controllers/proKerela/daily_prediction_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw; // PDF widgets
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class DailyPredictionResultScreen extends StatelessWidget {
  final DailyPredictionController controller = Get.find();

  // Re-declaring colors for clarity, ensure these match your actual theme.
  static const Color cosmicBlue = Color(0xFF1A2B42); // Deep, dark blue
  static const Color celestialGold = Color(0xFFD4AF37); // Rich gold
  static const Color stardustWhite = Color(0xFFF0F0F0); // Off-white for readability
  static const Color darkAccent = Color(0xFF2C3E50); // For darker gradient part
  static const Color mediumAccent = Color(0xFF34495E); // For medium gradient part

  // A map to get an icon based on the zodiac sign
  IconData _getZodiacIcon(String sign) {
    switch (sign.toLowerCase()) {
      case 'aries':
        return Icons.wb_sunny; // Represents fire/sun
      case 'taurus':
        return Icons.nature_people; // Earthy, grounded
      case 'gemini':
        return Icons.psychology; // Duality, mind
      case 'cancer':
        return Icons.water; // Emotional, water
      case 'leo':
        return Icons.local_fire_department; // Fire, passion
      case 'virgo':
        return Icons.eco; // Earthy, practical
      case 'libra':
        return Icons.balance; // Balance, justice
      case 'scorpio':
        return Icons.bolt; // Intensity, transformation
      case 'sagittarius':
        return Icons.travel_explore; // Adventure, exploration
      case 'capricorn':
        return Icons.landscape; // Earthy, ambitious
      case 'aquarius':
        return Icons.waves; // Air, innovation
      case 'pisces':
        return Icons.favorite; // Compassion, water
      default:
        return Icons.stars; // Default cosmic icon
    }
  }

  @override
  Widget build(BuildContext context) {
    final prediction = controller.prediction.value;
    final double topPadding = MediaQuery.of(context).padding.top + AppBar().preferredSize.height + 25;

    return Scaffold(
      extendBodyBehindAppBar: true, // Allow body to go behind app bar for gradient effect
      appBar: AppBar(
        title: Text(
          'Your Daily Horoscope',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: stardustWhite, // Consistent white title
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Transparent app bar
        elevation: 0, // No shadow
        iconTheme: const IconThemeData(color: stardustWhite, size: 28), // Larger back icon
      ),
      body: prediction == null
          ? Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [cosmicBlue, darkAccent, mediumAccent],
            stops: [0.1, 0.5, 0.9],
          ),
        ),
        child: Center(
          child: Text(
            'No prediction available.',
            style: GoogleFonts.poppins(fontSize: 18, color: stardustWhite),
          ),
        ),
      )
          : Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [cosmicBlue, darkAccent, mediumAccent],
            stops: [0.1, 0.5, 0.9],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: 25, right: 25, bottom: 25, top: topPadding),
          child: SingleChildScrollView(
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: celestialGold.withOpacity(0.8), width: 2), // Gold border
              ),
              color: cosmicBlue.withOpacity(0.85), // Semi-transparent dark blue
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Icon(
                        _getZodiacIcon(prediction.signName),
                        color: celestialGold,
                        size: 60, // Larger icon
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        prediction.signName.toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: celestialGold, // Use gold color
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Date: ${prediction.date}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: stardustWhite.withOpacity(0.8), // Softer white for date
                        ),
                      ),
                    ),
                    Divider(height: 30, thickness: 1.5, color: celestialGold.withOpacity(0.5)), // Gold divider
                    Text(
                      'Cosmic Insights', // More thematic title
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: celestialGold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      prediction.prediction,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        height: 1.5,
                        color: stardustWhite, // White text for prediction
                      ),
                    ),
                    // You can add more dynamic fields here if your prediction model has them
                    // e.g., lucky color, lucky number, mood
                    // SizedBox(height: 20),
                    // Text(
                    //   'Lucky Color: ${prediction.luckyColor}', // Assuming prediction.luckyColor exists
                    //   //   style: GoogleFonts.poppins(fontSize: 16, color: stardustWhite.withOpacity(0.8)),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: prediction == null
          ? null
          : FloatingActionButton.extended(
        onPressed: () async {
          await _generateAndSharePdf(context);
        },
        label: const Text('Download PDF'),
        icon: const Icon(Icons.picture_as_pdf),
        backgroundColor: celestialGold,
        foregroundColor: cosmicBlue,
      ),
    );
  }

  // --- PDF Generation Logic ---

  // Helper function to check if a string contains Malayalam characters
  bool _isMalayalam(String text) {
    // Unicode range for Malayalam script: U+0D00 to U+0D7F
    final malRe = RegExp(r'[\u0D00-\u0D7F]');
    return malRe.hasMatch(text);
  }

  // Helper function to check if a string contains Tamil characters
  bool _isTamil(String text) {
    // Unicode range for Tamil script: U+0B80 to U+0BFF
    final tamRe = RegExp(r'[\u0B80-\u0BFF]');
    return tamRe.hasMatch(text);
  }

  // Helper function to check if a string contains Hindi (Devanagari) characters
  bool _isHindi(String text) {
    // Unicode range for Devanagari script: U+0900 to U+097F
    final hindiRe = RegExp(r'[\u0900-\u097F]');
    return hindiRe.hasMatch(text);
  }

  // Helper function to determine the script of the text and return the appropriate font
  pw.Font? _getFontForText(String text, pw.Font? defaultFont, pw.Font? malayalamFont, pw.Font? tamilFont, pw.Font? hindiFont) {
    if (_isMalayalam(text) && malayalamFont != null) {
      return malayalamFont;
    } else if (_isTamil(text) && tamilFont != null) {
      return tamilFont;
    } else if (_isHindi(text) && hindiFont != null) {
      return hindiFont;
    }
    return defaultFont; // Fallback to default for English or other scripts
  }


  Future<void> _generateAndSharePdf(BuildContext context) async {
    try {
      final pdf = pw.Document();

      // Convert your static colors to PdfColor
      final PdfColor pdfCosmicBlue = PdfColor.fromInt(cosmicBlue.value);
      final PdfColor pdfCelestialGold = PdfColor.fromInt(celestialGold.value);
      final PdfColor pdfStardustWhite = PdfColors.black;

      // Fetch the prediction data safely
      final prediction = controller.prediction.value;
      if (prediction == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No prediction data available to generate PDF.')),
          );
        }
        return;
      }

      // --- Font Loading for PDF ---
      // Load a general font for English/Latin text
      pw.Font? defaultTextFont;
      try {
        final ByteData notoFontData = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
        defaultTextFont = pw.Font.ttf(notoFontData);
      } catch (e) {
        debugPrint('Failed to load NotoSans-Regular font for PDF: $e. Falling back to Helvetica.');
        defaultTextFont = pw.Font.helvetica(); // Fallback
      }

      // Load Malayalam font
      pw.Font? malayalamFont;
      try {
        final ByteData malayalamFontData = await rootBundle.load('assets/fonts/NotoSansMalayalam-Regular.ttf');
        malayalamFont = pw.Font.ttf(malayalamFontData);
      } catch (e) {
        debugPrint('Failed to load NotoSansMalayalam-Regular font for PDF: $e. Malayalam text might not render correctly.');
        malayalamFont = defaultTextFont; // Fallback to default if Malayalam font fails to load
      }

      // Load Tamil font
      pw.Font? tamilFont;
      try {
        final ByteData tamilFontData = await rootBundle.load('assets/fonts/NotoSansTamil-Regular.ttf');
        tamilFont = pw.Font.ttf(tamilFontData);
      } catch (e) {
        debugPrint('Failed to load NotoSansTamil-Regular font for PDF: $e. Tamil text might not render correctly.');
        tamilFont = defaultTextFont; // Fallback to default if Tamil font fails to load
      }

      // Load Hindi (Devanagari) font
      pw.Font? hindiFont;
      try {
        final ByteData hindiFontData = await rootBundle.load('assets/fonts/NotoSansDevanagari-Regular.ttf');
        hindiFont = pw.Font.ttf(hindiFontData);
      } catch (e) {
        debugPrint('Failed to load NotoSansDevanagari-Regular font for PDF: $e. Hindi text might not render correctly.');
        hindiFont = defaultTextFont; // Fallback to default if Hindi font fails to load
      }

      // Load Material Icons font for PDF icons
      pw.Font? materialIconsFont;
      try {
        final ByteData materialIconFontData = await rootBundle.load('assets/fonts/MaterialIcons-Regular.ttf');
        materialIconsFont = pw.Font.ttf(materialIconFontData);
      } catch (e) {
        debugPrint('Failed to load MaterialIcons font for PDF: $e. Icons might not render correctly.');
        // If material icons font fails, icons won't display. No easy fallback for specific icon glyphs.
        materialIconsFont = null; // Set to null to avoid errors if font is truly missing
      }
      // --- END Font Loading ---
      final ByteData imageBytes = await rootBundle.load('assets/images/finalLogo.png');
      final pw.MemoryImage logoImage = pw.MemoryImage(imageBytes.buffer.asUint8List());
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.copyWith(
            marginBottom: 1.5 * PdfPageFormat.cm,
            marginTop: 1.5 * PdfPageFormat.cm,
            marginLeft: 2.0 * PdfPageFormat.cm,
            marginRight: 2.0 * PdfPageFormat.cm,
          ),
          build: (pw.Context pwContext) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [

                pw.Center(
                  child:  pw.Image(logoImage, height: 40, width: 40),
                ),
                pw.Center(
                  child: pw.Text(
                    'Your Daily Horoscope',
                    style: pw.TextStyle(
                      fontSize: 26,
                      fontWeight: pw.FontWeight.bold,
                      color: pdfCosmicBlue,
                      font: defaultTextFont, // Use default font for English title
                    ),
                  ),
                ),
                pw.SizedBox(height: 25),
                pw.Center(
                  child: (materialIconsFont != null) // Only show icon if font loaded successfully
                      ? pw.Icon(
                    pw.IconData(_getZodiacIcon(prediction.signName).codePoint),
                    color: pdfCelestialGold,
                    size: 60,
                    font: materialIconsFont, // Use the loaded Material Icons font
                  )
                      : pw.Container(), // Empty container if font not loaded
                ),
                pw.SizedBox(height: 12),
                pw.Center(
                  child: pw.Text(
                    prediction.signName.toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: 28,
                      fontWeight: pw.FontWeight.bold,
                      color: pdfCelestialGold,
                      font: defaultTextFont, // Use default font for English sign name
                    ),
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Center(
                  child: pw.Text(
                    'Date: ${prediction.date}',
                    style: pw.TextStyle(
                      fontSize: 16,
                      color: pdfStardustWhite.shade(0.8),
                      font: defaultTextFont, // Use default font for date
                    ),
                  ),
                ),
                pw.Divider(height: 30, thickness: 1.5, color: pdfCelestialGold.shade(0.5)),
                pw.Text(
                  'Cosmic Insights',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: pdfCelestialGold,
                    font: defaultTextFont, // Use default font for English section title
                  ),
                ),
                pw.SizedBox(height: 10),
                // Use pw.Text for the prediction
                pw.Text(
                  prediction.prediction,
                  style: pw.TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: pdfStardustWhite,
                    font: _getFontForText(prediction.prediction, defaultTextFont, malayalamFont, tamilFont, hindiFont), // Apply multi-language font selection
                  ),
                  textAlign: pw.TextAlign.justify, // Justify the text
                  textDirection: _isMalayalam(prediction.prediction) || _isTamil(prediction.prediction) || _isHindi(prediction.prediction)
                      ? pw.TextDirection.ltr // Explicit LTR for Indic scripts if they are detected
                      : pw.TextDirection.ltr, // Default LTR
                ),
                // Add more prediction details here if available in your model
                // pw.SizedBox(height: 20),
                // pw.Text(
                //   'Lucky Color: ${prediction.luckyColor ?? 'N/A'}',
                //   style: pw.TextStyle(fontSize: 16, color: pdfStardustWhite.shade(0.8), font: pw.Font.helvetica()),
                // ),
              ],
            );
          },
        ),
      );

      // Save and share the PDF
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/daily_horoscope.pdf');
      await file.writeAsBytes(await pdf.save());

      if (context.mounted) {
        await Share.shareXFiles([XFile(file.path)], text: 'Your Daily Horoscope Report');
      }
    } catch (e) {
      debugPrint('Error generating PDF: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating PDF: ${e.toString()}')),
        );
      }
    }
  }
}